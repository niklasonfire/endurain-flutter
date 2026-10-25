import 'dart:async';

import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/features/statistics/controllers/statistics_controller.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/statistics_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class Repository implements StatisticsRepository {
  final requests = <Completer<ActivityStatistics>>[];
  @override
  Future<ActivityStatistics> fetch(StatisticsQuery query) {
    final result = Completer<ActivityStatistics>();
    requests.add(result);
    return result.future;
  }
}

/// Repository whose results carry offline read-cache provenance, like the
/// cached statistics repository does when it serves a cached view.
class CachedServingRepository
    implements StatisticsRepository, OfflineCacheProvenance {
  final Expando<OfflineCacheServeInfo> _provenance = Expando();

  /// When set, the next result is marked as served from the offline read
  /// cache at this time; a live result otherwise.
  DateTime? servedFetchedAt;

  @override
  OfflineCacheServeInfo? provenanceOf(Object result) => _provenance[result];

  @override
  Future<ActivityStatistics> fetch(StatisticsQuery query) async {
    // A fresh, non-const instance per fetch, like a live repository
    // returns: const instances are canonicalized and cannot carry
    // per-result provenance in an Expando.
    // ignore: prefer_const_constructors
    final result = ActivityStatistics(
      totals: StatisticsMetrics.zero,
      buckets: const [],
      sports: const [],
    );
    final fetchedAt = servedFetchedAt;
    if (fetchedAt != null) {
      _provenance[result] = OfflineCacheServeInfo(fetchedAt: fetchedAt);
    }
    return result;
  }
}

void main() {
  test(
    'account switch clears totals and rejects a late previous response',
    () async {
      final connection = ValueNotifier<String?>('a');
      final repository = Repository();
      final controller = StatisticsController(
        repository: repository,
        connection: connection,
      );
      final first = controller.refresh();
      connection.value = 'b';
      repository.requests.first.complete(ActivityStatistics.empty);
      await first;
      expect(controller.statistics, isNull);
      expect(controller.isLoading, isTrue);
      repository.requests.last.complete(ActivityStatistics.empty);
      await Future<void>.delayed(Duration.zero);
      expect(controller.statistics, isNotNull);
      connection.value = null;
      expect(controller.statistics, isNull);
      expect(controller.isGuest, isTrue);
      controller.dispose();
      connection.dispose();
    },
  );
  test(
    'failed refresh retains current totals and a successful retry clears error',
    () async {
      final connection = ValueNotifier<String?>('a');
      final repository = Repository();
      final controller = StatisticsController(
        repository: repository,
        connection: connection,
      );
      final initial = controller.refresh();
      repository.requests.last.complete(ActivityStatistics.empty);
      await initial;
      final refresh = controller.refresh();
      repository.requests.last.completeError(Exception('offline'));
      await refresh;
      expect(controller.statistics, same(ActivityStatistics.empty));
      expect(controller.error, isNotNull);
      expect(controller.isLoading, isFalse);
      final retry = controller.refresh();
      repository.requests.last.complete(ActivityStatistics.empty);
      await retry;
      expect(controller.error, isNull);
      controller.dispose();
      connection.dispose();
    },
  );
  test(
    'latest period wins and disposed controllers ignore late failures',
    () async {
      final connection = ValueNotifier<String?>('a');
      final repository = Repository();
      final controller = StatisticsController(
        repository: repository,
        connection: connection,
      );
      final first = controller.refresh();
      final second = controller.setQuery(
        StatisticsQuery(period: StatisticsPeriod.year),
      );
      repository.requests.first.completeError(Exception('stale'));
      await first;
      expect(controller.error, isNull);
      expect(controller.isLoading, isTrue);
      controller.dispose();
      repository.requests.last.completeError(Exception('disposed'));
      await second;
      connection.dispose();
    },
  );

  test(
    'a cached view exposes its fetch time and a live view does not',
    () async {
      final connection = ValueNotifier<String?>('a');
      final repository = CachedServingRepository();
      final controller = StatisticsController(
        repository: repository,
        connection: connection,
      );
      final cachedAt = DateTime.utc(2026, 10, 25, 9);
      repository.servedFetchedAt = cachedAt;
      var pending = controller.refresh();
      await pending;
      expect(controller.cacheFetchedAt, cachedAt);

      repository.servedFetchedAt = null;
      pending = controller.refresh();
      await pending;
      expect(controller.cacheFetchedAt, isNull);

      // A served result keeps its chip until the next refresh replaces it.
      repository.servedFetchedAt = cachedAt;
      pending = controller.refresh();
      await pending;
      expect(controller.cacheFetchedAt, cachedAt);

      connection.value = 'b';
      expect(controller.cacheFetchedAt, isNull);
      connection.value = null;
      expect(controller.cacheFetchedAt, isNull);
      controller.dispose();
      connection.dispose();
    },
  );
}
