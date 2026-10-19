import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:endurain/shared/state/safe_notifier.dart';
import 'package:endurain/features/activity/models/local_activity_record.dart';
import 'package:endurain/features/goals/models/goal_progress.dart';
import 'package:endurain/features/goals/repositories/goals_repository.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/statistics_repository.dart';

/// Independent home sections, bound to a connection and refresh generation.
class HomeController extends SafeNotifier {
  HomeController({
    required StatisticsRepository statisticsRepository,
    required ServerActivitiesRepository activitiesRepository,
    required GoalsRepository goalsRepository,
    required ValueListenable<String?> connection,
    Future<List<LocalActivityRecord>> Function()? loadLocalActivities,
    Future<int> Function()? loadPendingUploads,
    DateTime Function()? now,
  }) : _statistics = statisticsRepository,
       _activities = activitiesRepository,
       _goals = goalsRepository,
       _connection = connection,
       _loadLocalActivities = loadLocalActivities,
       _loadPendingUploads = loadPendingUploads,
       _now = now ?? DateTime.now {
    weekAnchor = _now().toUtc();
    _connection.addListener(_connectionChanged);
  }
  final StatisticsRepository _statistics;
  final ServerActivitiesRepository _activities;
  final GoalsRepository _goals;
  final ValueListenable<String?> _connection;
  final Future<List<LocalActivityRecord>> Function()? _loadLocalActivities;
  final DateTime Function() _now;
  final Future<int> Function()? _loadPendingUploads;
  int pendingUploads = 0;
  bool get hasPendingUploads => !isGuest && pendingUploads > 0;
  late DateTime weekAnchor;
  ActivityStatistics? statistics;
  List<ServerActivity> activities = const [];
  List<LocalActivityRecord> localActivities = const [];
  List<GoalProgress> goals = const [];
  Object? statisticsError;
  Object? activitiesError;
  Object? goalsError;
  bool statisticsLoading = false;
  bool activitiesLoading = false;
  bool goalsLoading = false;
  int _generation = 0;
  DateTime? _lastRefresh;
  bool get isGuest => _connection.value == null;
  List<GoalProgress> get visibleGoals => List.unmodifiable(goals.take(3));

  void _connectionChanged() {
    _generation++;
    statistics = null;
    activities = const [];
    localActivities = const [];
    goals = const [];
    pendingUploads = 0;
    statisticsError = activitiesError = goalsError = null;
    statisticsLoading = activitiesLoading = goalsLoading = false;
    _lastRefresh = null;
    notify();
    unawaited(refresh());
  }

  bool _current(int generation) => !isDisposed && generation == _generation;
  Future<void> refreshIfStale() async {
    final now = _now().toUtc();
    if (_lastRefresh == null ||
        now.difference(_lastRefresh!) >= const Duration(minutes: 5) ||
        now.day != weekAnchor.day ||
        now.month != weekAnchor.month ||
        now.year != weekAnchor.year) {
      await refresh();
    }
  }

  Future<void> refresh() async {
    if (isDisposed) return;
    final generation = ++_generation;
    final anchor = _now().toUtc();
    // A new UTC calendar day may cross any configured weekly boundary. Avoid
    // presenting the previous period's totals as the current week on failure.
    if (anchor.year != weekAnchor.year ||
        anchor.month != weekAnchor.month ||
        anchor.day != weekAnchor.day) {
      statistics = null;
    }
    goals = List.unmodifiable(
      goals.where((goal) {
        final day = DateTime.utc(anchor.year, anchor.month, anchor.day);
        return !day.isBefore(goal.startDate) && !day.isAfter(goal.endDate);
      }),
    );
    weekAnchor = anchor;
    statisticsError = activitiesError = goalsError = null;
    statisticsLoading = activitiesLoading = true;
    goalsLoading = !isGuest;
    notify();
    if (isGuest) {
      goals = const [];
      await _loadGuest(generation);
    } else {
      await Future.wait([
        _loadStatistics(generation),
        _loadActivities(generation),
        _loadGoals(generation),
        _loadPending(generation),
      ]);
    }
    if (_current(generation)) {
      // Failures remain immediately retryable on the next resume.
      if (statisticsError == null &&
          activitiesError == null &&
          goalsError == null) {
        _lastRefresh = _now().toUtc();
      }
    }
  }

  Future<void> _loadPending(int generation) async {
    try {
      final result = await _loadPendingUploads?.call() ?? 0;
      if (_current(generation)) {
        pendingUploads = result;
        notify();
      }
    } catch (_) {
      // Optional queue status must never hide server activities or totals.
    }
  }

  Future<void> _loadStatistics(int generation) async {
    try {
      final result = await _statistics.fetch(StatisticsQuery(date: weekAnchor));
      if (_current(generation)) statistics = result;
    } catch (error) {
      if (_current(generation)) statisticsError = error;
    } finally {
      if (_current(generation)) {
        statisticsLoading = false;
        notify();
      }
    }
  }

  Future<void> _loadActivities(int generation) async {
    try {
      final result = await _activities.fetchPage(pageSize: 3);
      if (_current(generation)) {
        activities = List.unmodifiable(result.items.take(3));
      }
    } catch (error) {
      if (_current(generation)) activitiesError = error;
    } finally {
      if (_current(generation)) {
        activitiesLoading = false;
        notify();
      }
    }
  }

  Future<void> _loadGoals(int generation) async {
    try {
      final result = await _goals.fetchResults();
      final ordered = [...result]
        ..sort((a, b) {
          const order = {'weekly': 0, 'daily': 1, 'monthly': 2, 'yearly': 3};
          final interval = order[a.interval]!.compareTo(order[b.interval]!);
          return interval != 0 ? interval : a.id.compareTo(b.id);
        });
      if (_current(generation)) goals = List.unmodifiable(ordered);
    } catch (error) {
      if (_current(generation)) goalsError = error;
    } finally {
      if (_current(generation)) {
        goalsLoading = false;
        notify();
      }
    }
  }

  Future<void> _loadGuest(int generation) async {
    try {
      final records =
          await _loadLocalActivities?.call() ?? <LocalActivityRecord>[];
      final guest =
          records
              .where(
                (r) =>
                    r.connectionOrigin == null && r.connectionProfileId == null,
              )
              .toList()
            ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      if (_current(generation)) {
        localActivities = List.unmodifiable(guest.take(3));
        statistics = _guestStatistics(guest);
      }
    } catch (error) {
      if (_current(generation)) {
        statisticsError = error;
        activitiesError = error;
      }
    } finally {
      if (_current(generation)) {
        statisticsLoading = activitiesLoading = false;
        notify();
      }
    }
  }

  ActivityStatistics _guestStatistics(List<LocalActivityRecord> records) {
    final date = DateTime.utc(
      weekAnchor.year,
      weekAnchor.month,
      weekAnchor.day,
    );
    final start = date.subtract(Duration(days: date.weekday - 1));
    final end = start.add(const Duration(days: 7));
    final week = records
        .where(
          (r) =>
              !r.startedAt.toUtc().isBefore(start) &&
              r.startedAt.toUtc().isBefore(end),
        )
        .toList();
    StatisticsMetrics metrics(Iterable<LocalActivityRecord> rows) => rows.fold(
      StatisticsMetrics.zero,
      (m, r) => StatisticsMetrics(
        distanceMeters: m.distanceMeters + r.distanceMeters,
        durationSeconds: m.durationSeconds + r.elapsedDurationSeconds,
        elevationMeters: m.elevationMeters + (r.elevationGainMeters ?? 0),
        count: m.count + 1,
      ),
    );
    final types = week.map((r) => r.activityType).toSet();
    return ActivityStatistics(
      totals: metrics(week),
      buckets: [
        for (var d = 0; d < 7; d++)
          StatisticsBucket(
            d,
            metrics(week.where((r) => r.startedAt.toUtc().weekday - 1 == d)),
          ),
      ],
      sports: [
        for (final type in types)
          StatisticsSport(
            id: switch (type.apiValue) {
              'run' => 1,
              'ride' => 2,
              'walk' => 4,
              'hike' => 5,
              _ => 19,
            },
            apiName: type.apiValue,
            metrics: metrics(week.where((r) => r.activityType == type)),
          ),
      ],
    );
  }

  Future<List<ServerRoutePoint>> loadRoute(int activityId) async {
    final generation = _generation;
    if (isGuest || isDisposed) return const [];
    try {
      final result = await _activities.fetchRoute(activityId);
      return _current(generation) ? result : const [];
    } catch (_) {
      return const [];
    }
  }

  @override
  void dispose() {
    _generation++;
    _connection.removeListener(_connectionChanged);
    super.dispose();
  }
}
