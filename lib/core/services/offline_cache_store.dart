/// Offline read cache foundation (ADR-0001).
///
/// A local, raw-payload copy of what the server already returned, served for
/// viewing while offline. The server remains the source of truth; offline is
/// read-only.
library;

/// One cached raw server payload, keyed by identity (see `ConnectionProfile`),
/// concept, and canonical query.
///
/// The payload is stored exactly as the server returned it — decoded JSON,
/// not parsed models — so a server schema change breaks parsing at read time
/// exactly as it would a live fetch (ADR-0001).
class OfflineCacheEntry {
  const OfflineCacheEntry({
    required this.profileId,
    required this.concept,
    required this.query,
    required this.payload,
    required this.fetchedAt,
  });

  /// `ConnectionProfile.id` (origin-qualified) this entry belongs to. Cached
  /// data is never served to another identity.
  final String profileId;

  /// Server concept this payload answers, e.g. `activity-list`.
  final String concept;

  /// Canonical, sorted, encoded request parameters of the fetch.
  final String query;

  /// Raw decoded JSON payload as returned by the server.
  final Object? payload;

  /// When the server was last successfully reached for this payload. Drives
  /// the "Last updated" chip.
  final DateTime fetchedAt;
}

/// Provenance of a repository result served from the offline read cache.
class OfflineCacheServeInfo {
  const OfflineCacheServeInfo({required this.fetchedAt});

  /// When the cached payload was last fetched from the server.
  final DateTime fetchedAt;
}

/// Optional capability of a repository that can report which of its results
/// came from the offline read cache. The result object itself carries the
/// answer, so concurrent fetches cannot mix up provenance.
abstract interface class OfflineCacheProvenance {
  /// Provenance of [result] when it was served from the offline read cache;
  /// `null` when it came from the server.
  OfflineCacheServeInfo? provenanceOf(Object result);
}

/// Persistent raw-payload store behind the offline read cache (ADR-0001).
abstract interface class OfflineCacheStore {
  /// Returns the cached entry for the identity/concept/query, or `null`.
  Future<OfflineCacheEntry?> read({
    required String profileId,
    required String concept,
    required String query,
  });

  /// Stores [entry], replacing any previous entry for the same key.
  Future<void> write(OfflineCacheEntry entry);

  /// Removes every entry of [profileId]; returns the number of removed rows.
  Future<int> clearForProfile(String profileId);

  /// Removes every cached entry of every identity.
  Future<void> clearAll();
}

/// Composes the identity-qualified cache key (decision D2):
/// `<ConnectionProfile.id> | <concept> | <canonical query>`.
String offlineCacheKey({
  required String profileId,
  required String concept,
  required String query,
}) => '$profileId|$concept|$query';

/// Canonicalizes request parameters into a stable, sorted, encoded form so
/// the same fetch always maps to the same cache key (decision D2).
String canonicalCacheQuery(Map<String, String> params) {
  final keys = params.keys.toList()..sort();
  return [
    for (final key in keys)
      '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(params[key]!)}',
  ].join('&');
}
