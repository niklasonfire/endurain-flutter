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
/// through the same helpers as a live fetch.
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
  static const String _detailConceptPrefix = 'activity-detail:';
  static const String _routeConceptPrefix = 'activity-route:';
  static const String _streamsConceptPrefix = 'activity-streams:';
  static const String _lapsConceptPrefix = 'activity-laps:';

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
  }) {
    final canonicalQuery = canonicalCacheQuery(
      ApiServerActivitiesRepository.activityListQueryParameters(
        query: query,
        page: page,
        pageSize: pageSize,
      ),
    );
    return _fetchThroughCache(
      concept: _listConcept,
      query: canonicalQuery,
      fetchEnvelope: () => _inner.fetchActivityListEnvelope(
        query: query,
        page: page,
        pageSize: pageSize,
      ),
      parse: (envelope) =>
          ApiServerActivitiesRepository.parseActivityListEnvelope(
            envelope: envelope,
            page: page,
            pageSize: pageSize,
          ),
    );
  }

  @override
  Future<List<int>> fetchActivityTypes() => _fetchThroughCache(
    concept: _typesConcept,
    query: '',
    fetchEnvelope: _inner.fetchActivityTypesEnvelope,
    parse: ApiServerActivitiesRepository.parseActivityTypesEnvelope,
  );

  @override
  Future<ServerActivity> fetchDetail(int activityId) => _fetchThroughCache(
    concept: '$_detailConceptPrefix$activityId',
    query: '',
    fetchEnvelope: () => _inner.fetchDetailEnvelope(activityId),
    parse: (envelope) => ApiServerActivitiesRepository.parseDetailEnvelope(
      envelope: envelope,
      activityId: activityId,
    ),
  );

  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) =>
      _fetchThroughCache(
        concept: '$_routeConceptPrefix$activityId',
        query: '',
        fetchEnvelope: () => _inner.fetchRouteStreamEnvelope(activityId),
        parse: (envelope) =>
            ApiServerActivitiesRepository.parseRouteStreamEnvelope(
              envelope: envelope,
              activityId: activityId,
            ),
      );

  @override
  Future<List<ServerActivityGraph>> fetchGraphs(int activityId) =>
      _fetchThroughCache(
        concept: '$_streamsConceptPrefix$activityId',
        query: canonicalCacheQuery(
          ApiServerActivitiesRepository.detailRowsQueryParameters,
        ),
        fetchEnvelope: () => _inner.fetchActivityStreamsEnvelope(activityId),
        parse: (envelope) => ApiServerActivitiesRepository.parseGraphsEnvelope(
          envelope: envelope,
          activityId: activityId,
        ),
      );

  @override
  Future<List<ServerActivityLap>> fetchLaps(int activityId) =>
      _fetchThroughCache(
        concept: '$_lapsConceptPrefix$activityId',
        query: canonicalCacheQuery(
          ApiServerActivitiesRepository.detailRowsQueryParameters,
        ),
        fetchEnvelope: () => _inner.fetchActivityLapsEnvelope(activityId),
        parse: (envelope) => ApiServerActivitiesRepository.parseLapsEnvelope(
          envelope: envelope,
          activityId: activityId,
        ),
      );

  /// Cache-through fetch of one raw envelope (decision D1): a live fetch is
  /// written to the cache for the active identity; a fetch that fails
  /// because the server was unreachable falls back to the cached payload of
  /// the same identity, re-parsed through the same helper as a live fetch.
  ///
  /// The cache is best-effort, like the identity wiper: a store failure
  /// (corrupt database, full disk) must never turn a successful live fetch
  /// into an error — online behavior stays unchanged — and on the offline
  /// path a failing read lets the original fetch error surface.
  Future<T> _fetchThroughCache<T extends Object>({
    required String concept,
    required String query,
    required Future<Object?> Function() fetchEnvelope,
    required T Function(Object? envelope) parse,
  }) async {
    // The identity that started the fetch keys any later cache write: a
    // switch mid-flight must never file the outgoing identity's payload
    // under the incoming one.
    final profileAtFetchStart = await _connectionProfile();
    Object? envelope;
    try {
      envelope = await fetchEnvelope();
    } on AppException catch (error) {
      final cached = await _serveFromCache(
        error,
        concept: concept,
        query: query,
      );
      if (cached != null) {
        return _markCacheServed(parse(cached.payload), cached.fetchedAt);
      }
      rethrow;
    }
    // Re-resolve the identity after the await: the session may have changed
    // while the request was in flight. The inner repository already rejects a
    // mid-fetch switch, so this only guards the cache write's key.
    final profile = await _connectionProfile();
    if (profile != null && profile.id == profileAtFetchStart?.id) {
      try {
        await _cacheStore.write(
          OfflineCacheEntry(
            profileId: profile.id,
            concept: concept,
            query: query,
            payload: envelope,
            fetchedAt: _clock().toUtc(),
          ),
        );
      } catch (_) {
        // A failing store must not fail a successful live fetch; the next
        // successful fetch retries the write.
      }
    }
    return parse(envelope);
  }

  /// Reads the cache for the active identity after a failed fetch.
  ///
  /// Returns `null` — leaving the original error to propagate — unless the
  /// failure is genuinely network-ish (decision D3), the session still
  /// resolves to a profile (decision D5: guest mode never reads the cache),
  /// and the cache holds an entry for that identity. A store that cannot be
  /// read also yields `null` so the fetch failure itself surfaces.
  Future<OfflineCacheEntry?> _serveFromCache(
    AppException error, {
    required String concept,
    required String query,
  }) async {
    if (!_isOfflineFetchFailure(error)) return null;
    final profile = await _connectionProfile();
    if (profile == null) return null;
    try {
      return await _cacheStore.read(
        profileId: profile.id,
        concept: concept,
        query: query,
      );
    } catch (_) {
      // The cache is best-effort; the original fetch error is the truth.
      return null;
    }
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
