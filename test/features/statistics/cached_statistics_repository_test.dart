import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/api_statistics_repository.dart';
import 'package:endurain/features/statistics/repositories/cached_statistics_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const _profileA = ConnectionProfile(
  id: 'https://a.test#account-a',
  origin: 'https://a.test',
  kind: ConnectionKind.selfHosted,
);

const _profileB = ConnectionProfile(
  id: 'https://b.test#account-b',
  origin: 'https://b.test',
  kind: ConnectionKind.selfHosted,
);

Object? _summaryEnvelope() => {
  'total_distance': 10000,
  'total_duration': 3600,
  'total_elevation_gain': 120,
  'activity_count': 1,
  'breakdown': [
    {
      'week_number': 3,
      'total_distance': 10000,
      'total_duration': 3600,
      'total_elevation_gain': 120,
      'activity_count': 1,
    },
  ],
  'type_breakdown': [
    {
      'activity_type_id': 1,
      'activity_type': 'Run workout',
      'total_distance': 10000,
      'total_duration': 3600,
      'total_elevation_gain': 120,
      'activity_count': 1,
    },
  ],
};

class _FakeStore implements OfflineCacheStore {
  final Map<String, OfflineCacheEntry> entries = {};

  int readCalls = 0;

  /// When set, [read] simulates a broken store (corrupt DB, full disk).
  bool failReads = false;

  /// When set, [write] simulates a broken store (corrupt DB, full disk).
  bool failWrites = false;

  @override
  Future<OfflineCacheEntry?> read({
    required String profileId,
    required String concept,
    required String query,
  }) async {
    readCalls++;
    if (failReads) throw StateError('offline cache unreadable');
    return entries[offlineCacheKey(
      profileId: profileId,
      concept: concept,
      query: query,
    )];
  }

  @override
  Future<void> write(OfflineCacheEntry entry) async {
    if (failWrites) throw StateError('offline cache unwritable');
    entries[offlineCacheKey(
          profileId: entry.profileId,
          concept: entry.concept,
          query: entry.query,
        )] =
        entry;
  }

  @override
  Future<int> clearForProfile(String profileId) async {
    final doomed = entries.keys
        .where((key) => entries[key]!.profileId == profileId)
        .toList();
    entries.removeWhere((key, value) => value.profileId == profileId);
    return doomed.length;
  }

  @override
  Future<void> clearAll() async {
    entries.clear();
  }
}

class _FakeRawSource implements StatisticsRawSource {
  Object? envelope = _summaryEnvelope();

  /// Error thrown by the envelope fetch, simulating a fetch failure
  /// (network, session, format, ...).
  AppException? error;

  int calls = 0;
  final requests = <StatisticsQuery>[];

  /// Invoked when the envelope fetch starts, letting a test simulate an
  /// account switch while the request is in flight.
  void Function()? onEnvelopeFetch;

  void goOffline() {
    error = const AppException(AppErrorCode.serverActivitiesFetchFailed);
  }

  @override
  Future<Object?> fetchStatisticsEnvelope(StatisticsQuery query) async {
    calls++;
    requests.add(query);
    onEnvelopeFetch?.call();
    final error = this.error;
    if (error != null) throw error;
    return envelope;
  }

  @override
  Future<ActivityStatistics> fetch(StatisticsQuery query) =>
      throw UnimplementedError();
}

void main() {
  late _FakeStore store;
  late _FakeRawSource inner;
  late ConnectionProfile? profile;
  DateTime now = DateTime.utc(2026, 10, 25, 9);

  CachedStatisticsRepository makeRepository() => CachedStatisticsRepository(
    inner: inner,
    cacheStore: store,
    connectionProfile: () async => profile,
    clock: () => now,
  );

  setUp(() {
    store = _FakeStore();
    inner = _FakeRawSource();
    profile = _profileA;
    now = DateTime.utc(2026, 10, 25, 9);
  });

  test('a successful statistics fetch stores the raw envelope for the identity', () async {
    final repository = makeRepository();
    final query = StatisticsQuery(
      period: StatisticsPeriod.month,
      date: DateTime(2026, 10, 18),
    );

    final result = await repository.fetch(query);

    expect(result.totals.count, 1);
    expect(repository.provenanceOf(result), isNull);
    final entry = store.entries.values.single;
    expect(entry.profileId, _profileA.id);
    expect(entry.concept, 'statistics');
    expect(entry.payload, _summaryEnvelope());
    expect(entry.fetchedAt, DateTime.utc(2026, 10, 25, 9));
    expect(
      entry.query,
      canonicalCacheQuery(
        ApiStatisticsRepository.statisticsQueryParameters(query: query),
      ),
    );
  });
}
