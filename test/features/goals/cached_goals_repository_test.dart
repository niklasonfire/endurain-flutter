import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/features/goals/repositories/cached_goals_repository.dart';
import 'package:endurain/features/goals/repositories/goals_repository.dart';
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

const _runGoalRow = {
  'goal_id': 7,
  'interval': 'weekly',
  'activity_type': 'run',
  'goal_type': 'duration',
  'start_date': '2026-10-19',
  'end_date': '2026-10-25',
  'percentage_completed': 75,
  'goal_duration': 7200,
  'total_duration': 5400,
};

const _rideGoalRow = {
  'goal_id': 8,
  'interval': 'daily',
  'activity_type': 'bike',
  'goal_type': 'distance',
  'start_date': '2026-10-25',
  'end_date': '2026-10-25',
  'percentage_completed': 40,
  'goal_distance': 50000,
  'total_distance': 20000,
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
  Future<void> clearAll() {
    entries.clear();
    return Future.value();
  }
}

class _FakeRawSource implements GoalsRawSource {
  Object? envelope = const [_runGoalRow];

  /// Error thrown by the envelope fetch, simulating a fetch failure
  /// (network, session, format, ...).
  AppException? error;

  int calls = 0;

  /// Invoked when the envelope fetch starts, letting a test simulate an
  /// account switch while the request is in flight.
  void Function()? onEnvelopeFetch;

  void goOffline() {
    error = const AppException(AppErrorCode.serverActivitiesFetchFailed);
  }

  @override
  Future<Object?> fetchResultsEnvelope() async {
    calls++;
    onEnvelopeFetch?.call();
    final error = this.error;
    if (error != null) throw error;
    return envelope;
  }
}

void main() {
  late _FakeStore store;
  late _FakeRawSource inner;
  late ConnectionProfile? profile;
  DateTime now = DateTime.utc(2026, 10, 25, 9);

  CachedGoalsRepository makeRepository() => CachedGoalsRepository(
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
    'a successful fetch stores the raw goal results for the identity',
    () async {
      final repository = makeRepository();

      final goals = await repository.fetchResults();

      expect(goals.single.id, 7);
      expect(goals.single.target, 7200);
      final entry = store.entries.values.single;
      expect(entry.profileId, _profileA.id);
      expect(entry.concept, 'goals');
      expect(entry.query, '');
      expect(entry.payload, const [_runGoalRow]);
      expect(entry.fetchedAt, DateTime.utc(2026, 10, 25, 9));
    },
  );

  test('a live result carries no cache provenance', () async {
    final repository = makeRepository();

    final goals = await repository.fetchResults();

    expect(repository.provenanceOf(goals), isNull);
  });

  test('every successful fetch refreshes the cached copy', () async {
    final repository = makeRepository();
    await repository.fetchResults();
    inner.envelope = const [_rideGoalRow];
    now = DateTime.utc(2026, 10, 25, 10);

    await repository.fetchResults();

    expect(store.entries.values.single.payload, const [_rideGoalRow]);
    expect(
      store.entries.values.single.fetchedAt,
      DateTime.utc(2026, 10, 25, 10),
    );
  });

  test(
    'a failing cache write never turns a successful live fetch into an error',
    () async {
      final repository = makeRepository();
      store.failWrites = true;

      final goals = await repository.fetchResults();

      expect(goals.single.id, 7);
      expect(repository.provenanceOf(goals), isNull);
      expect(store.entries, isEmpty);
    },
  );

  test(
    'a failing cache read lets the original fetch failure surface',
    () async {
      final repository = makeRepository();
      await repository.fetchResults();
      inner.goOffline();
      inner.envelope = null;
      store.failReads = true;

      await expectLater(
        repository.fetchResults(),
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

  test('an account switch mid-flight never keys the cache write', () async {
    final repository = makeRepository();
    inner.onEnvelopeFetch = () => profile = _profileB;

    final goals = await repository.fetchResults();

    expect(goals.single.id, 7);
    expect(store.entries, isEmpty);
  });

  test('a network failure falls back to the cached goals', () async {
    final repository = makeRepository();
    await repository.fetchResults();
    inner.goOffline();
    inner.envelope = null;

    final goals = await repository.fetchResults();

    expect(inner.calls, 2);
    expect(goals.single.id, 7);
    final provenance = repository.provenanceOf(goals);
    expect(provenance, isNotNull);
    expect(provenance!.fetchedAt, DateTime.utc(2026, 10, 25, 9));
  });

  test('a request timeout falls back to the cached goals', () async {
    final repository = makeRepository();
    await repository.fetchResults();
    inner.error = const AppException(AppErrorCode.requestTimeout);

    final goals = await repository.fetchResults();

    expect(goals.single.id, 7);
    expect(repository.provenanceOf(goals), isNotNull);
  });

  test('cached data of another identity is never served', () async {
    final repository = makeRepository();
    await repository.fetchResults();
    profile = _profileB;
    inner.goOffline();

    await expectLater(repository.fetchResults(), throwsA(isA<AppException>()));
    expect(store.entries.values.single.profileId, _profileA.id);
  });

  test('without a cached copy the fetch failure surfaces', () async {
    final repository = makeRepository();
    inner.goOffline();

    await expectLater(repository.fetchResults(), throwsA(isA<AppException>()));
  });

  test('session and authentication failures never fall back', () async {
    final repository = makeRepository();
    await repository.fetchResults();

    for (final code in [
      AppErrorCode.sessionExpired,
      AppErrorCode.notAuthenticated,
      AppErrorCode.unexpectedResponseFormat,
    ]) {
      inner.error = AppException(code);
      await expectLater(
        repository.fetchResults(),
        throwsA(
          isA<AppException>().having((error) => error.code, 'code', code),
        ),
      );
    }
  });

  test('an HTTP error status never falls back', () async {
    final repository = makeRepository();
    await repository.fetchResults();
    inner.error = const AppException(
      AppErrorCode.serverActivitiesFetchFailed,
      statusCode: 500,
    );

    await expectLater(
      repository.fetchResults(),
      throwsA(
        isA<AppException>().having((error) => error.statusCode, 'status', 500),
      ),
    );
  });

  test(
    'guest mode behaves like the inner repository and never reads the cache',
    () async {
      final repository = makeRepository();
      await repository.fetchResults();
      profile = null;
      inner.error = const AppException(AppErrorCode.notAuthenticated);
      store.readCalls = 0;

      await expectLater(
        repository.fetchResults(),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            AppErrorCode.notAuthenticated,
          ),
        ),
      );

      expect(store.readCalls, 0);
    },
  );

  test('a null envelope (no goals) is cached and served offline', () async {
    final repository = makeRepository();
    inner.envelope = null;
    expect(await repository.fetchResults(), isEmpty);
    expect(store.entries.values.single.payload, isNull);

    inner.goOffline();
    final goals = await repository.fetchResults();
    expect(goals, isEmpty);
    expect(repository.provenanceOf(goals), isNotNull);
  });
}
