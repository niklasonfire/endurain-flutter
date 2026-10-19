import 'dart:async';
import 'dart:isolate';

import 'package:endurain/core/models/app_exception.dart';

import 'package:endurain/shared/state/safe_notifier.dart';
import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/services/auth_session_store.dart';

import 'package:endurain/features/achievements/models/achievement_models.dart';
import 'package:endurain/features/achievements/repositories/achievements_repository.dart';
import 'package:endurain/features/achievements/services/achievement_calculator.dart';
import 'package:endurain/features/achievements/services/achievement_server_source.dart';

/// App-lifetime analysis workflow; routes observe it without owning the scan.
class AchievementScanService extends SafeNotifier {
  AchievementScanService({
    required AchievementsRepository repository,
    required AchievementServerSource source,
    required AuthSessionStore sessionStore,
  }) : _repository = repository,
       _source = source,
       _sessions = sessionStore {
    _sessions.connectionChanges.addListener(_connectionChanged);
  }
  final AchievementsRepository _repository;
  final AchievementServerSource _source;
  final AuthSessionStore _sessions;
  AchievementSnapshot? _snapshot;
  AchievementSnapshot? get snapshot => _snapshot;
  bool _loading = false, _scanning = false, _disposed = false;
  bool get isLoading => _loading;
  bool get isScanning => _scanning;
  bool get isGuest => _scope == null;
  String? _scope;
  AppException? _error;
  AppException? get error => _error;
  int _generation = 0;

  void _notify() {
    if (!_disposed) notify();
  }

  void _connectionChanged() {
    if (_sessions.connectionChanges.value == _scope) return;
    final firstScopeRead = _scope == null && _loading;
    if (!firstScopeRead) _generation++;
    _scope = _sessions.connectionChanges.value;
    _snapshot = null;
    _error = null;
    _scanning = false;
    _notify();
    if (!firstScopeRead) unawaited(initialize());
  }

  Future<void> initialize() async {
    if (_disposed || _scanning) return;
    final generation = ++_generation;
    _loading = true;
    _notify();
    try {
      final session = await _sessions.readSession();
      if (_disposed || generation != _generation) return;
      _scope = session?.profileId;
      if (session == null) {
        _snapshot = null;
        return;
      }
      final snapshot = await _repository.load(session.profileId);
      if (_disposed ||
          generation != _generation ||
          (await _sessions.readSession())?.profileId != session.profileId) {
        return;
      }
      _snapshot = snapshot;
      _error = null;
    } catch (error) {
      if (generation == _generation) {
        _error = _failure(AppErrorCode.achievementCacheFailed, error);
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _loading = false;
        _notify();
      }
    }
  }

  Future<void> cancel() async {
    if (_disposed) return;
    final wasScanning = _scanning;
    final generation = ++_generation;
    _scanning = false;
    _loading = false;
    _notify();
    if (!wasScanning) return;
    try {
      final session = await _sessions.readSession();
      if (session == null) return;
      await _check(session, generation);
      final prior = await _repository.loadScanState(session.profileId);
      await _check(session, generation);
      if (prior == null) return;
      await _repository.saveScanState(
        session.profileId,
        AchievementScanState(
          generation: generation,
          status: AchievementScanStatus.partial,
          rebuildInProgress: prior.rebuildInProgress,
          pendingRebuildIds: prior.pendingRebuildIds,
          inventoryIds: prior.inventoryIds,
          processedCount: prior.processedCount,
          totalCount: prior.totalCount,
          usableTrackCount: prior.usableTrackCount,
          unavailableTrackCount: prior.unavailableTrackCount,
          failures: prior.failures,
          skipped: prior.skipped,
          nextPage: prior.nextPage,
          firstDayOfWeek: prior.firstDayOfWeek,
          lastSuccessfulAt: prior.lastSuccessfulAt,
        ),
      );
      await _publish(session, generation);
    } on _ScanCancelled {
      /* A newer scan or account owns the state. */
    } catch (error) {
      if (!_disposed && generation == _generation) {
        _error = _failure(AppErrorCode.achievementCacheFailed, error);
        _notify();
      }
    }
  }

  Future<void> _check(AuthSession session, int generation) async {
    if (_disposed || generation != _generation) throw const _ScanCancelled();
    final current = await _sessions.readSession();
    if (_disposed ||
        generation != _generation ||
        current?.profileId != session.profileId) {
      throw const _ScanCancelled();
    }
  }

  Future<void> _publish(AuthSession session, int generation) async {
    await _check(session, generation);
    final snapshot = await _repository.load(session.profileId);
    await _check(session, generation);
    _snapshot = snapshot;
    _notify();
  }

  Future<Map<int, AchievementActivity>> _inventory(
    AuthSession session,
    int generation,
    int userId,
    int expectedCount,
  ) async {
    final found = <int, AchievementActivity>{};
    const size = 100;
    // Always restart page one: durable offsets cannot survive inserts/deletes.
    for (
      var page = 1;
      page <= (expectedCount / size).ceil().clamp(1, 1000000);
      page++
    ) {
      final rows = await _source.fetchPage(
        session,
        userId: userId,
        page: page,
        pageSize: size,
      );
      await _check(session, generation);
      final expectedPageSize = (expectedCount - found.length).clamp(0, size);
      if (rows.length != expectedPageSize) throw const _InventoryChanged();
      for (final row in rows) {
        if (found.containsKey(row.id)) throw const _InventoryChanged();
        found[row.id] = row;
      }
    }
    if (found.length != expectedCount) throw const _InventoryChanged();
    final count = await _source.fetchCount(session);
    await _check(session, generation);
    if (count != expectedCount) throw const _InventoryChanged();
    return found;
  }

  Future<void> scan({bool rebuild = false}) async {
    if (_disposed || _scanning) return;
    final session = await _sessions.readSession();
    if (_disposed || _scanning || session == null) return;
    final generation = ++_generation;
    _scope = session.profileId;
    _loading = false;
    _scanning = true;
    _error = null;
    _notify();
    var inventoryIds = <int>[];
    var processed = 0, total = 0, usable = 0, unavailable = 0;
    final failures = <int, String>{};
    final skipped = <int, List<String>>{};
    var nextPage = 1;
    var rebuilding = rebuild;
    final pendingRebuild = <int>{};
    int? firstDay;
    DateTime? lastSuccessful;
    AchievementScanState state(AchievementScanStatus status, {String? error}) =>
        AchievementScanState(
          generation: generation,
          rebuildInProgress: rebuilding,
          pendingRebuildIds: pendingRebuild.toList()..sort(),
          status: status,
          inventoryIds: List.unmodifiable(inventoryIds),
          processedCount: processed,
          totalCount: total,
          usableTrackCount: usable,
          unavailableTrackCount: unavailable,
          failures: Map.unmodifiable(failures),
          skipped: Map.unmodifiable(skipped),
          nextPage: nextPage,
          firstDayOfWeek: firstDay,
          lastSuccessfulAt: lastSuccessful,
          error: error,
        );
    final publishClock = Stopwatch()..start();
    try {
      final prior = await _repository.loadScanState(session.profileId);
      await _check(session, generation);
      // A traversal can stop before revisiting an activity. Keep its durable
      // retry/quality metadata until that activity is refreshed or deleted.
      failures.addAll(prior?.failures ?? const <int, String>{});
      skipped.addAll(prior?.skipped ?? const <int, List<String>>{});
      rebuilding = rebuild || (prior?.rebuildInProgress ?? false);
      if (!rebuild) {
        pendingRebuild.addAll(prior?.pendingRebuildIds ?? const <int>[]);
      }
      lastSuccessful = prior?.lastSuccessfulAt;
      firstDay = prior?.firstDayOfWeek;
      final oldAnalyses = await _repository.loadAnalyses(session.profileId);
      await _check(session, generation);
      final cached = {for (final a in oldAnalyses) a.activity.id: a};
      final owner = await _source.fetchOwner(session);
      await _check(session, generation);
      firstDay = owner.firstDayOfWeek;
      total = await _source.fetchCount(session);
      await _check(session, generation);
      await _repository.saveScanState(
        session.profileId,
        state(AchievementScanStatus.scanning),
      );
      await _publish(session, generation);
      final inventory = await _inventory(
        session,
        generation,
        owner.userId,
        total,
      );
      inventoryIds = inventory.keys.toList();
      // Two consistent full passes reduce offset-pagination races; detail 404
      // confirmation remains mandatory because the server offers no snapshot.
      final confirmation = await _inventory(
        session,
        generation,
        owner.userId,
        total,
      );
      if (inventory.length != confirmation.length ||
          inventory.entries.any(
            (e) => confirmation[e.key]?.fingerprint != e.value.fingerprint,
          )) {
        throw const _InventoryChanged();
      }
      if (rebuilding && (rebuild || pendingRebuild.isEmpty)) {
        pendingRebuild.addAll(inventory.keys);
      }
      pendingRebuild.retainAll(inventory.keys);
      await _repository.saveScanState(
        session.profileId,
        state(AchievementScanStatus.scanning),
      );
      await _check(session, generation);
      for (final activity in inventory.values) {
        await _check(session, generation);
        final existing = cached[activity.id];
        final reuse =
            !pendingRebuild.contains(activity.id) &&
            existing?.activity.fingerprint == activity.fingerprint &&
            existing?.calculationVersion ==
                AchievementCalculator.calculationVersion &&
            !failures.containsKey(activity.id);
        AchievementAnalysis? analysis;
        if (reuse) {
          analysis = existing;
          final reasons = prior?.skipped[activity.id] ?? const <String>[];
          if (reasons.isNotEmpty) skipped[activity.id] = reasons;
          if (AchievementCalculator.distancesForSport(activity.sportType)
              .isNotEmpty) {
            if (reasons.contains('gpsUnavailable') ||
                reasons.contains('gpsNoContinuousTravel')) {
              unavailable++;
            } else {
              usable++;
            }
          }
        } else {
          try {
            final track = await _source.fetchTrack(session, activity);
            await _check(session, generation);
            skipped.remove(activity.id);
            if (track.reasons.isNotEmpty) skipped[activity.id] = track.reasons;
            if (AchievementCalculator.distancesForSport(activity.sportType)
                .isNotEmpty) {
              if (track.reasons.contains('gpsUnavailable') ||
                  track.reasons.contains('gpsNoContinuousTravel')) {
                unavailable++;
              } else {
                usable++;
              }
            }
            analysis = await Isolate.run(
              () => const AchievementCalculator().analyze(track.activity),
            );
            await _check(session, generation);
            pendingRebuild.remove(activity.id);
            failures.remove(activity.id);
          } on _ScanCancelled {
            rethrow;
          } catch (_) {
            await _check(session, generation);
            failures[activity.id] = 'activityFetchFailed';
            // A new activity still contributes summaries while GPS is retryable.
            if (existing == null) {
              analysis = await Isolate.run(
                () => const AchievementCalculator().analyze(activity),
              );
              await _check(session, generation);
            }
          }
        }
        if (activity.startedAt == null) {
          skipped[activity.id] = <String>{
            ...?skipped[activity.id],
            'missingAbsoluteDate',
          }.toList();
        }
        processed++;
        nextPage = (processed ~/ 100) + 1;
        if (analysis != null) {
          await _repository.replaceAnalysis(
            session.profileId,
            analysis,
            checkpoint: state(AchievementScanStatus.scanning),
          );
        } else {
          await _repository.saveScanState(
            session.profileId,
            state(AchievementScanStatus.scanning),
          );
        }
        if (processed % 20 == 0 || publishClock.elapsedMilliseconds >= 1000) {
          await _publish(session, generation);
          publishClock.reset();
        }
      }
      rebuilding = pendingRebuild.isNotEmpty;
      final deleted = <int>{};
      final previouslyKnownIds = <int>{
        ...cached.keys,
        ...failures.keys,
        ...skipped.keys,
      };
      for (final old in previouslyKnownIds.where(
        (id) => !inventory.containsKey(id),
      )) {
        try {
          final gone = await _source.isDeleted(session, old);
          await _check(session, generation);
          if (gone) {
            deleted.add(old);
            failures.remove(old);
            skipped.remove(old);
          } else {
            failures[old] = 'inventoryChanged';
          }
        } on _ScanCancelled {
          rethrow;
        } catch (_) {
          await _check(session, generation);
          failures[old] = 'deletionUnconfirmed';
        }
      }
      await _check(session, generation);
      if (failures.isEmpty) {
        lastSuccessful = DateTime.now().toUtc();
        await _repository.completeInventory(
          session.profileId,
          confirmedDeletedIds: deleted,
          state: state(AchievementScanStatus.complete),
        );
      } else {
        await _repository.saveScanState(
          session.profileId,
          state(AchievementScanStatus.partial),
        );
      }
      await _publish(session, generation);
    } on _ScanCancelled {
      // Account/generation ownership has moved. Do not publish late results.
    } catch (error) {
      try {
        await _check(session, generation);
        _error = _failure(AppErrorCode.achievementScanFailed, error);
        await _repository.saveScanState(
          session.profileId,
          state(AchievementScanStatus.failed, error: _error?.code.name),
        );
        await _publish(session, generation);
      } on _ScanCancelled {
        /* Ownership moved while handling failure. */
      } catch (error) {
        if (!_disposed && generation == _generation) {
          _error = _failure(AppErrorCode.achievementCacheFailed, error);
        }
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _scanning = false;
        _notify();
      }
    }
  }

  // Auth failures retain the shared session semantics; other failures carry
  // feature context without losing the original storage/network exception.
  AppException _failure(AppErrorCode code, Object cause) {
    if (cause is AppException &&
        (cause.code == AppErrorCode.notAuthenticated ||
            cause.code == AppErrorCode.sessionExpired ||
            cause.code == AppErrorCode.transientAuthUnavailable)) {
      return cause;
    }
    return AppException(code, cause: cause);
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _sessions.connectionChanges.removeListener(_connectionChanged);
    super.dispose();
  }
}

class _ScanCancelled implements Exception {
  const _ScanCancelled();
}

class _InventoryChanged implements Exception {
  const _InventoryChanged();
}
