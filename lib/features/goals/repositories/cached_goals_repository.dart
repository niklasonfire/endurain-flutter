import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/core/services/offline_cache_through.dart';
import 'package:endurain/features/goals/models/goal_progress.dart';
import 'package:endurain/features/goals/repositories/api_goals_repository.dart';
import 'package:endurain/features/goals/repositories/goals_repository.dart';

/// Cache-through decorator over the goals results repository (ADR-0001).
///
/// Every successful fetch writes the raw server payload to the offline read
/// cache; a fetch that fails because the server could not be reached falls
/// back to the cached payload of the **active identity** only, re-parsed
/// through the same helper as a live fetch.
class CachedGoalsRepository implements GoalsRepository, OfflineCacheProvenance {
  CachedGoalsRepository({
    required GoalsRawSource inner,
    required OfflineCacheStore cacheStore,
    required Future<ConnectionProfile?> Function() connectionProfile,
    DateTime Function() clock = DateTime.now,
  }) : _inner = inner,
       _cache = OfflineCacheThrough(
         cacheStore: cacheStore,
         connectionProfile: connectionProfile,
         clock: clock,
       );

  static const String _resultsConcept = 'goals';

  final GoalsRawSource _inner;
  final OfflineCacheThrough _cache;

  @override
  OfflineCacheServeInfo? provenanceOf(Object result) =>
      _cache.provenanceOf(result);

  @override
  Future<List<GoalProgress>> fetchResults() => _cache.fetch(
    concept: _resultsConcept,
    query: '',
    fetchEnvelope: _inner.fetchResultsEnvelope,
    parse: ApiGoalsRepository.parseResultsEnvelope,
  );
}
