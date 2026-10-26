import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/services/offline_cache_store.dart';

/// Cache-through machinery shared by the offline read-cache decorators
/// (ADR-0001): a live fetch of one raw envelope is written to the cache for
/// the active identity, and a fetch that fails because the server could not
/// be reached falls back to the cached payload of the same identity,
/// re-parsed through the same helper as a live fetch.
///
/// The cache is best-effort, like the identity wiper: a store failure
/// (corrupt database, full disk) must never turn a successful live fetch
/// into an error — online behavior stays unchanged — and on the offline
/// path a failing read lets the original fetch error surface.
class OfflineCacheThrough implements OfflineCacheProvenance {
  OfflineCacheThrough({
    required OfflineCacheStore cacheStore,
    required Future<ConnectionProfile?> Function() connectionProfile,
    DateTime Function() clock = DateTime.now,
  }) : _cacheStore = cacheStore,
       _connectionProfile = connectionProfile,
       _clock = clock;

  final OfflineCacheStore _cacheStore;
  final Future<ConnectionProfile?> Function() _connectionProfile;
  final DateTime Function() _clock;
  final Expando<OfflineCacheServeInfo> _provenance =
      Expando<OfflineCacheServeInfo>();

  @override
  OfflineCacheServeInfo? provenanceOf(Object result) => _provenance[result];

  /// Cache-through fetch of one raw envelope (decision D1), parameterized on
  /// the cache concept, the raw envelope fetch, and the parse shared by
  /// live and cached serves.
  Future<T> fetch<T extends Object>({
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
