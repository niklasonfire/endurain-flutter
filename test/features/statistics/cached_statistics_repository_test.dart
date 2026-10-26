import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/api_statistics_repository.dart';
import 'package:endurain/features/statistics/repositories/cached_statistics_repository.dart';
import 'package:endurain/features/statistics/repositories/statistics_repository.dart';
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

StatisticsQuery _query({
  StatisticsPeriod period = StatisticsPeriod.week,
  DateTime? date,
  StatisticsSport? sport,
}) => StatisticsQuery(
  period: period,
  date: date ?? DateTime(2026, 10, 18),
  sport: sport,
);

Object? _summaryEnvelope({StatisticsPeriod period = StatisticsPeriod.week}) => {
  'total_distance': 10000,
  'total_duration': 3600,
  'total_elevation_gain': 120,
  'activity_count': 1,
  'breakdown': [
    {
      switch (period) {
        StatisticsPeriod.week => 'day_of_week',
        StatisticsPeriod.month => 'week_number',
        StatisticsPeriod.year => 'month_number',
      }: 3,
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
  /// Envelope the server answers with; defaults to a valid payload for the
  /// requested period.
  Object? envelope;

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
    return envelope ?? _summaryEnvelope(period: query.period);
  }
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

  test(
    'a successful statistics fetch stores the raw envelope for the identity',
    () async {
      final repository = makeRepository();
      final query = _query(period: StatisticsPeriod.month);

      final result = await repository.fetch(query);

      expect(result.totals.count, 1);
      expect(repository.provenanceOf(result), isNull);
      final entry = store.entries.values.single;
      expect(entry.profileId, _profileA.id);
      expect(entry.concept, 'statistics');
      expect(entry.payload, _summaryEnvelope(period: StatisticsPeriod.month));
      expect(entry.fetchedAt, DateTime.utc(2026, 10, 25, 9));
      expect(
        entry.query,
        canonicalCacheQuery(
          ApiStatisticsRepository.statisticsQueryParameters(query: query),
        ),
      );
    },
  );

  test('every successful statistics fetch refreshes the cached copy', () async {
    final repository = makeRepository();
    await repository.fetch(_query());
    now = DateTime.utc(2026, 10, 25, 10);

    await repository.fetch(_query());

    expect(store.entries, hasLength(1));
    expect(
      store.entries.values.single.fetchedAt,
      DateTime.utc(2026, 10, 25, 10),
    );
  });

  test(
    'a failing cache write never turns a successful fetch into an error',
    () async {
      final repository = makeRepository();
      store.failWrites = true;

      final result = await repository.fetch(_query());

      expect(result.totals.count, 1);
      expect(repository.provenanceOf(result), isNull);
      expect(store.entries, isEmpty);
    },
  );

  test(
    'a network failure falls back to the cached payload with provenance',
    () async {
      final repository = makeRepository();
      await repository.fetch(_query());
      inner.goOffline();
      inner.envelope = null;

      final result = await repository.fetch(_query());

      expect(inner.calls, 2);
      expect(result.totals.count, 1);
      expect(
        repository.provenanceOf(result)!.fetchedAt,
        DateTime.utc(2026, 10, 25, 9),
      );
    },
  );

  test('a request timeout falls back to the cached payload', () async {
    final repository = makeRepository();
    await repository.fetch(_query());
    inner.error = const AppException(AppErrorCode.requestTimeout);

    final result = await repository.fetch(_query());

    expect(result.totals.count, 1);
    expect(repository.provenanceOf(result), isNotNull);
  });

  test(
    'a cached summary is only served for its own period, date, and sport',
    () async {
      final repository = makeRepository();
      final query = _query(period: StatisticsPeriod.month);
      await repository.fetch(query);
      inner.goOffline();

      await expectLater(
        repository.fetch(_query()),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        repository.fetch(
          _query(period: StatisticsPeriod.month, date: DateTime(2026, 9)),
        ),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        repository.fetch(
          _query(
            period: StatisticsPeriod.month,
            sport: const StatisticsSport(
              id: 1,
              apiName: 'Run',
              metrics: StatisticsMetrics.zero,
            ),
          ),
        ),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        repository.fetch(_query(period: StatisticsPeriod.year)),
        throwsA(isA<AppException>()),
      );

      // The query the cache was written for still serves offline.
      final cached = await repository.fetch(query);
      expect(repository.provenanceOf(cached), isNotNull);
    },
  );

  test(
    'statistics never fetched while online surface the fetch failure',
    () async {
      final repository = makeRepository();
      inner.goOffline();

      await expectLater(
        repository.fetch(_query()),
        throwsA(isA<AppException>()),
      );
      expect(store.readCalls, 1);
      expect(store.entries, isEmpty);
    },
  );

  test('cached data of another identity is never served', () async {
    final repository = makeRepository();
    await repository.fetch(_query());
    profile = _profileB;
    inner.goOffline();

    await expectLater(repository.fetch(_query()), throwsA(isA<AppException>()));
    expect(store.entries.values.single.profileId, _profileA.id);
  });

  test('an account switch mid-flight never keys the cache write', () async {
    final repository = makeRepository();
    inner.onEnvelopeFetch = () => profile = _profileB;

    final result = await repository.fetch(_query());

    expect(result.totals.count, 1);
    expect(store.entries, isEmpty);
  });

  test(
    'session, authentication, and format failures never fall back',
    () async {
      final repository = makeRepository();
      await repository.fetch(_query());

      for (final code in [
        AppErrorCode.sessionExpired,
        AppErrorCode.notAuthenticated,
        AppErrorCode.unexpectedResponseFormat,
        AppErrorCode.transientAuthUnavailable,
      ]) {
        inner.error = AppException(code);
        await expectLater(
          repository.fetch(_query()),
          throwsA(
            isA<AppException>().having((error) => error.code, 'code', code),
          ),
        );
      }
    },
  );

  test('an HTTP error status never falls back', () async {
    final repository = makeRepository();
    await repository.fetch(_query());
    inner.error = const AppException(
      AppErrorCode.serverActivitiesFetchFailed,
      statusCode: 500,
    );

    await expectLater(
      repository.fetch(_query()),
      throwsA(
        isA<AppException>().having((error) => error.statusCode, 'status', 500),
      ),
    );
  });

  test('guest mode never reads the cache', () async {
    final repository = makeRepository();
    await repository.fetch(_query());
    profile = null;
    inner.error = const AppException(AppErrorCode.notAuthenticated);
    store.readCalls = 0;

    await expectLater(
      repository.fetch(_query()),
      throwsA(
        isA<AppException>().having(
          (error) => error.code,
          'code',
          AppErrorCode.notAuthenticated,
        ),
      ),
    );

    expect(store.readCalls, 0);
  });

  test(
    'a failing cache read lets the original fetch failure surface',
    () async {
      final repository = makeRepository();
      await repository.fetch(_query());
      inner.goOffline();
      inner.envelope = null;
      store.failReads = true;

      await expectLater(
        repository.fetch(_query()),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            AppErrorCode.serverActivitiesFetchFailed,
          ),
        ),
      );
    },
  );
}
