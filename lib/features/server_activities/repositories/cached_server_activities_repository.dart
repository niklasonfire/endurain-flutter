import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/api_server_activities_repository.dart';
import 'package:endurain/features/server_activities/repositories/server_activity_graph_repository.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';

/// Cache-through decorator over the server activity repositories
/// (ADR-0001).
///
/// Every successful fetch writes the raw server envelope to the offline read
/// cache; a fetch that fails because the server could not be reached falls
/// back to the cached payload of the **active identity** only, re-parsed
/// through the same helpers as a live fetch. Everything else — detail, route,
/// graphs, laps — passes straight through until later tickets extend the
/// cache to them.
class CachedServerActivitiesRepository
    implements
        ServerActivitiesRepository,
        ServerActivityGraphRepository,
        OfflineCacheProvenance {
  CachedServerActivitiesRepository({
    required ServerActivitiesRawSource inner,
    required OfflineCacheStore cacheStore,
    required Future<ConnectionProfile?> Function() connectionProfile,
    DateTime Function() clock = DateTime.now,
  }) : _inner = inner,
       _cacheStore = cacheStore,
       _connectionProfile = connectionProfile,
       _clock = clock;

  static const String _listConcept = 'activity-list';
  static const String _typesConcept = 'activity-types';

  final ServerActivitiesRawSource _inner;
  final OfflineCacheStore _cacheStore;
  final Future<ConnectionProfile?> Function() _connectionProfile;
  final DateTime Function() _clock;
  final Expando<OfflineCacheServeInfo> _provenance =
      Expando<OfflineCacheServeInfo>();

  @override
  OfflineCacheServeInfo? provenanceOf(Object result) => _provenance[result];

  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) async {
    final canonicalQuery = canonicalCacheQuery(
      ApiServerActivitiesRepository.activityListQueryParameters(
        query: query,
        page: page,
        pageSize: pageSize,
      ),
    );
    Object? envelope;
    try {
      envelope = await _inner.fetchActivityListEnvelope(
        query: query,
        page: page,
        pageSize: pageSize,
      );
    } on AppException catch (error) {
      final cached = await _serveFromCache(
        error,
        concept: _listConcept,
        query: canonicalQuery,
      );
      if (cached != null) {
        final result = ApiServerActivitiesRepository.parseActivityListEnvelope(
          envelope: cached.payload,
          page: page,
          pageSize: pageSize,
        );
        return _markCacheServed(result, cached.fetchedAt);
      }
      rethrow;
    }
    // Re-resolve the identity after the await: the session may have changed
    // while the request was in flight. The inner repository already rejects a
    // mid-fetch switch, so this only guards the cache write's key.
    final profile = await _connectionProfile();
    if (profile != null) {
      await _cacheStore.write(
        OfflineCacheEntry(
          profileId: profile.id,
          concept: _listConcept,
          query: canonicalQuery,
          payload: envelope,
          fetchedAt: _clock().toUtc(),
        ),
      );
    }
    return ApiServerActivitiesRepository.parseActivityListEnvelope(
      envelope: envelope,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<List<int>> fetchActivityTypes() async {
    Object? envelope;
    try {
      envelope = await _inner.fetchActivityTypesEnvelope();
    } on AppException catch (error) {
      final cached = await _serveFromCache(
        error,
        concept: _typesConcept,
        query: '',
      );
      if (cached != null) {
        return _markCacheServed(
          ApiServerActivitiesRepository.parseActivityTypesEnvelope(
            cached.payload,
          ),
          cached.fetchedAt,
        );
      }
      rethrow;
    }
    final profile = await _connectionProfile();
    if (profile != null) {
      await _cacheStore.write(
        OfflineCacheEntry(
          profileId: profile.id,
          concept: _typesConcept,
          query: '',
          payload: envelope,
          fetchedAt: _clock().toUtc(),
        ),
      );
    }
    return ApiServerActivitiesRepository.parseActivityTypesEnvelope(envelope);
  }

  @override
  Future<ServerActivity> fetchDetail(int activityId) =>
      _inner.fetchDetail(activityId);

  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) =>
      _inner.fetchRoute(activityId);

  @override
  Future<List<ServerActivityGraph>> fetchGraphs(int activityId) =>
      _inner.fetchGraphs(activityId);

  @override
  Future<List<ServerActivityLap>> fetchLaps(int activityId) =>
      _inner.fetchLaps(activityId);

  /// Reads the cache for the active identity after a failed fetch.
  ///
  /// Returns `null` — leaving the original error to propagate — unless the
  /// failure is genuinely network-ish (decision D3), the session still
  /// resolves to a profile (decision D5: guest mode never reads the cache),
  /// and the cache holds an entry for that identity.
  Future<OfflineCacheEntry?> _serveFromCache(
    AppException error, {
    required String concept,
    required String query,
  }) async {
    if (!_isOfflineFetchFailure(error)) return null;
    final profile = await _connectionProfile();
    if (profile == null) return null;
    return _cacheStore.read(
      profileId: profile.id,
      concept: concept,
      query: query,
    );
  }

  /// A failure is offline-cache-worthy only when the server could not be
  /// reached at all: the fetch failure or a timeout, with no HTTP status —
  /// a status means the server answered, and session, authentication,
  /// format, and transient-refresh errors keep their live meaning instead of
  /// being masked by stale data (decision D3, pitfalls 5 and 8).
  static bool _isOfflineFetchFailure(AppException error) {
    if (error.statusCode != null) return false;
    return error.code == AppErrorCode.serverActivitiesFetchFailed ||
        error.code == AppErrorCode.requestTimeout;
  }

  T _markCacheServed<T extends Object>(T result, DateTime fetchedAt) {
    _provenance[result] = OfflineCacheServeInfo(fetchedAt: fetchedAt);
    return result;
  }
}
