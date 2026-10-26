import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/core/services/offline_cache_through.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/api_statistics_repository.dart';
import 'package:endurain/features/statistics/repositories/statistics_repository.dart';

/// Cache-through decorator over the statistics repository (ADR-0001).
///
/// Every successful fetch writes the raw server envelope to the offline read
/// cache; a fetch that fails because the server could not be reached falls
/// back to the cached payload of the **active identity** only, re-parsed
/// through the same helpers as a live fetch.
class CachedStatisticsRepository
    implements StatisticsRepository, OfflineCacheProvenance {
  CachedStatisticsRepository({
    required StatisticsRawSource inner,
    required OfflineCacheStore cacheStore,
    required Future<ConnectionProfile?> Function() connectionProfile,
    DateTime Function() clock = DateTime.now,
  }) : _inner = inner,
       _cache = OfflineCacheThrough(
         cacheStore: cacheStore,
         connectionProfile: connectionProfile,
         clock: clock,
       );

  static const String _concept = 'statistics';

  final StatisticsRawSource _inner;
  final OfflineCacheThrough _cache;

  @override
  OfflineCacheServeInfo? provenanceOf(Object result) =>
      _cache.provenanceOf(result);

  @override
  Future<ActivityStatistics> fetch(StatisticsQuery query) {
    final canonicalQuery = canonicalCacheQuery(
      ApiStatisticsRepository.statisticsQueryParameters(query: query),
    );
    return _cache.fetch(
      concept: _concept,
      query: canonicalQuery,
      fetchEnvelope: () => _inner.fetchStatisticsEnvelope(query),
      parse: (envelope) => ApiStatisticsRepository.parseStatisticsEnvelope(
        envelope: envelope,
        period: query.period,
      ),
    );
  }
}
