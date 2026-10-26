import 'package:endurain/features/activity/models/local_activity_record.dart';
import 'package:endurain/features/activity/models/activity_type.dart';

import 'dart:async';

import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/features/home/controllers/home_controller.dart';
import 'package:endurain/features/goals/models/goal_progress.dart';
import 'package:endurain/features/goals/repositories/goals_repository.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/statistics_repository.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class Summary implements StatisticsRepository {
  final requests = <Completer<ActivityStatistics>>[];
  final queries = <StatisticsQuery>[];
  @override
  Future<ActivityStatistics> fetch(StatisticsQuery query) {
    queries.add(query);
    final c = Completer<ActivityStatistics>();
    requests.add(c);
    return c.future;
  }
}

class Goals implements GoalsRepository {
  @override
  Future<List<GoalProgress>> fetchResults() async => [];
}

class Activities implements ServerActivitiesRepository {
  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) async => ServerActivityPage(
    items: [
      const ServerActivity(
        id: 1,
        name: 'Run',
        activityType: 1,
        distanceMeters: 5000,
      ),
    ],
    page: page,
    pageSize: pageSize,
    total: 99,
  );
  @override
  Future<List<int>> fetchActivityTypes() async => [];
  @override
  Future<ServerActivity> fetchDetail(int id) async =>
      throw UnimplementedError();
  @override
  Future<List<ServerRoutePoint>> fetchRoute(int id) async => [];
}

void main() {
  test('weekly totals come from full summary while activities load independently and stale totals survive offline refresh', () async {
    final connection = ValueNotifier<String?>('a');
    final repository = Summary();
    final controller = HomeController(
      statisticsRepository: repository,
      activitiesRepository: Activities(),
      goalsRepository: Goals(),
      connection: connection,
      now: () => DateTime.utc(2026, 10, 19),
    );
    final loading = controller.refresh();
    await Future<void>.delayed(Duration.zero);
    expect(controller.activities.single.id, 1);
    expect(controller.statisticsLoading, true);
    expect(repository.queries.single.period, StatisticsPeriod.week);
    const full = ActivityStatistics(
      totals: StatisticsMetrics(
        distanceMeters: 100000,
        durationSeconds: 36000,
        elevationMeters: 1000,
        count: 30,
      ),
      buckets: [],
      sports: [],
    );
    repository.requests.single.complete(full);
    await loading;
    expect(controller.statistics!.totals.count, 30);
    final retry = controller.refresh();
    repository.requests.last.completeError(Exception('offline'));
    await retry;
    expect(controller.statistics, same(full));
    expect(controller.statisticsError, isNotNull);
    expect(controller.activitiesError, isNull);
    controller.dispose();
    connection.dispose();
  });
  test(
    'account switch immediately clears all sections and ignores late responses',
    () async {
      final connection = ValueNotifier<String?>('a');
      final repository = Summary();
      final controller = HomeController(
        statisticsRepository: repository,
        activitiesRepository: Activities(),
        goalsRepository: Goals(),
        connection: connection,
      );
      final first = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(controller.activities, isNotEmpty);
      connection.value = 'b';
      expect(controller.activities, isEmpty);
      expect(controller.statistics, isNull);
      repository.requests.first.complete(ActivityStatistics.empty);
      await first;
      expect(controller.statistics, isNull);
      expect(controller.statisticsLoading, true);
      repository.requests.last.complete(ActivityStatistics.empty);
      await Future<void>.delayed(Duration.zero);
      expect(controller.statistics, same(ActivityStatistics.empty));
      controller.dispose();
      connection.dispose();
    },
  );

  test(
    'week rollover clears old goals even when their refresh fails',
    () async {
      var now = DateTime.utc(2026, 10, 25);
      final connection = ValueNotifier<String?>('a');
      final repository = Summary();
      final goal = GoalProgress(
        id: 1,
        interval: 'weekly',
        activityType: 'run',
        goalType: 'distance',
        startDate: DateTime.utc(2026, 10, 19),
        endDate: DateTime.utc(2026, 10, 25),
        achieved: 20000,
        target: 25000,
        percentage: 80,
      );
      final goals = VariableGoals([goal]);
      final controller = HomeController(
        statisticsRepository: repository,
        activitiesRepository: Activities(),
        goalsRepository: goals,
        connection: connection,
        now: () => now,
      );
      final initial = controller.refresh();
      repository.requests.last.complete(ActivityStatistics.empty);
      await initial;
      now = DateTime.utc(2026, 10, 26);
      goals.failure = true;
      final refresh = controller.refreshIfStale();
      repository.requests.last.completeError(Exception('offline'));
      await refresh;
      expect(controller.goals, isEmpty);
      expect(controller.statistics, isNull);
      controller.dispose();
      connection.dispose();
    },
  );
  test(
    'guest summarizes all local guest records and hides former account records',
    () async {
      final connection = ValueNotifier<String?>(null);
      final repository = Summary();
      final controller = HomeController(
        statisticsRepository: repository,
        activitiesRepository: Activities(),
        goalsRepository: Goals(),
        connection: connection,
        now: () => DateTime.utc(2026, 10, 21),
        loadLocalActivities: () async => [
          for (var i = 0; i < 5; i++)
            localRecord('$i', DateTime.utc(2026, 10, 19 + i % 3)),
          localRecord('account', DateTime.utc(2026, 10, 21), profile: 'old'),
          localRecord('previous-week', DateTime.utc(2026, 10, 18)),
        ],
      );
      await controller.refresh();
      expect(repository.requests, isEmpty);
      expect(controller.localActivities, hasLength(3));
      expect(
        controller.localActivities.any((r) => r.connectionProfileId != null),
        false,
      );
      expect(controller.statistics!.totals.count, 5);
      expect(controller.statistics!.totals.durationSeconds, 15000);
      expect(controller.statistics!.distanceMeters, 25000);
      expect(controller.statistics!.buckets.map((b) => b.metrics.count), [
        2,
        2,
        1,
        0,
        0,
        0,
        0,
      ]);
      expect(controller.goals, isEmpty);
      controller.dispose();
      connection.dispose();
    },
  );

  test('weekly goals appear first and only three are featured while all remain accessible', () async {
    final connection = ValueNotifier<String?>('a');
    final repository = Summary();
    GoalProgress goal(int id, String interval) => GoalProgress(
      id: id,
      interval: interval,
      activityType: 'run',
      goalType: 'distance',
      startDate: DateTime.utc(2026, 10, 19),
      endDate: DateTime.utc(2026, 10, 25),
      achieved: 1000,
      target: 5000,
      percentage: 20,
    );
    final controller = HomeController(
      statisticsRepository: repository,
      activitiesRepository: Activities(),
      goalsRepository: VariableGoals([
        goal(1, 'yearly'),
        goal(2, 'monthly'),
        goal(3, 'daily'),
        goal(4, 'weekly'),
      ]),
      connection: connection,
    );
    final loading = controller.refresh();
    repository.requests.single.complete(ActivityStatistics.empty);
    await loading;
    expect(controller.visibleGoals.map((g) => g.id), [4, 3, 2]);
    expect(controller.goals, hasLength(4));
    controller.dispose();
    connection.dispose();
  });
  test('successful refresh clears stale goal cards after the final goal is deleted', () async {
    final connection = ValueNotifier<String?>('a');
    final summary = Summary();
    final goals = VariableGoals([
      GoalProgress(
        id: 1,
        interval: 'weekly',
        activityType: 'run',
        goalType: 'distance',
        startDate: DateTime.utc(2026, 10, 19),
        endDate: DateTime.utc(2026, 10, 25),
        achieved: 1000,
        target: 5000,
        percentage: 20,
      ),
    ]);
    final controller = HomeController(
      statisticsRepository: summary,
      activitiesRepository: Activities(),
      goalsRepository: goals,
      connection: connection,
      now: () => DateTime.utc(2026, 10, 19),
    );
    final initial = controller.refresh();
    summary.requests.last.complete(ActivityStatistics.empty);
    await initial;
    expect(controller.visibleGoals, hasLength(1));
    goals.values.clear();
    final refreshed = controller.refresh();
    summary.requests.last.complete(ActivityStatistics.empty);
    await refreshed;
    expect(controller.goals, isEmpty);
    expect(controller.visibleGoals, isEmpty);
    expect(controller.goalsError, isNull);
    expect(controller.goalsLoading, isFalse);
    controller.dispose();
    connection.dispose();
  });
  test('goals served from the offline cache expose their fetch time', () async {
    final connection = ValueNotifier<String?>('a');
    final repository = Summary();
    final goals = OfflineAwareGoals();
    final controller = HomeController(
      statisticsRepository: repository,
      activitiesRepository: Activities(),
      goalsRepository: goals,
      connection: connection,
    );
    final initial = controller.refresh();
    repository.requests.single.complete(ActivityStatistics.empty);
    await initial;
    expect(controller.goalsCacheFetchedAt, isNull);

    goals.fromCache = DateTime.utc(2026, 10, 25, 9);
    final refreshed = controller.refresh();
    repository.requests.last.complete(ActivityStatistics.empty);
    await refreshed;
    expect(controller.goalsCacheFetchedAt, DateTime.utc(2026, 10, 25, 9));

    goals.fromCache = null;
    final live = controller.refresh();
    repository.requests.last.complete(ActivityStatistics.empty);
    await live;
    expect(controller.goalsCacheFetchedAt, isNull);
    controller.dispose();
    connection.dispose();
  });
  test('an account switch clears the goals cache timestamp', () async {
    final connection = ValueNotifier<String?>('a');
    final repository = Summary();
    final goals = OfflineAwareGoals();
    final controller = HomeController(
      statisticsRepository: repository,
      activitiesRepository: Activities(),
      goalsRepository: goals,
      connection: connection,
    );
    goals.fromCache = DateTime.utc(2026, 10, 25, 9);
    final loading = controller.refresh();
    repository.requests.single.complete(ActivityStatistics.empty);
    await loading;
    expect(controller.goalsCacheFetchedAt, DateTime.utc(2026, 10, 25, 9));

    // The new identity fetches live; the old identity's timestamp must not
    // survive the account switch.
    goals.fromCache = null;
    connection.value = 'b';
    await Future<void>.delayed(Duration.zero);
    expect(controller.goalsCacheFetchedAt, isNull);
    controller.dispose();
    connection.dispose();
  });
}

/// Goals repository that reports which results came from the offline read
/// cache, like CachedGoalsRepository.
class OfflineAwareGoals implements GoalsRepository, OfflineCacheProvenance {
  DateTime? fromCache;
  @override
  Future<List<GoalProgress>> fetchResults() async => const [];
  @override
  OfflineCacheServeInfo? provenanceOf(Object result) =>
      fromCache == null ? null : OfflineCacheServeInfo(fetchedAt: fromCache!);
}

class VariableGoals implements GoalsRepository {
  VariableGoals(this.values);
  final List<GoalProgress> values;
  bool failure = false;
  @override
  Future<List<GoalProgress>> fetchResults() async {
    if (failure) throw Exception('offline');
    return values;
  }
}

LocalActivityRecord localRecord(String id, DateTime date, {String? profile}) =>
    LocalActivityRecord(
      id: id,
      activityType: ActivityType.run,
      startedAt: date,
      endedAt: date.add(const Duration(minutes: 50)),
      elapsedDurationSeconds: 3000,
      distanceMeters: 5000,
      pointCount: 2,
      gpxFileName: '$id.gpx',
      uploadStatus: LocalActivityUploadStatus.pending,
      createdAt: date,
      updatedAt: date,
      connectionProfileId: profile,
      connectionOrigin: profile == null ? null : 'https://old.test',
    );
