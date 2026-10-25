import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/api_server_activities_repository.dart';
import 'package:endurain/features/server_activities/repositories/cached_server_activities_repository.dart';
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

Object? _listEnvelope(List<Map<String, Object?>> rows, int total) => {
  'items': rows,
  'total': total,
};

const _runRow = {'id': 1, 'activity_type': 1, 'name': 'Morning run'};
const _rideRow = {'id': 2, 'activity_type': 4, 'name': 'Evening ride'};

class _FakeStore implements OfflineCacheStore {
  final Map<String, OfflineCacheEntry> entries = {};

  int readCalls = 0;

  @override
  Future<OfflineCacheEntry?> read({
    required String profileId,
    required String concept,
    required String query,
  }) async {
    readCalls++;
    return entries[offlineCacheKey(
      profileId: profileId,
      concept: concept,
      query: query,
    )];
  }

  @override
  Future<void> write(OfflineCacheEntry entry) async {
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

class _FakeRawSource implements ServerActivitiesRawSource {
  Object? listEnvelope;
  Object? typesEnvelope = const {'1': 'Run', '4': 'Ride'};

  /// Error thrown by the list/types envelope fetches, simulating a fetch
  /// failure (network, session, format, ...).
  AppException? listError;
  AppException? typesError;

  int listCalls = 0;
  int typesCalls = 0;
  final listRequests =
      <({ServerActivityQuery query, int page, int pageSize})>[];
  int detailCalls = 0;
  int routeCalls = 0;
  int graphsCalls = 0;
  int lapsCalls = 0;

  void goOffline() {
    listError = const AppException(AppErrorCode.serverActivitiesFetchFailed);
    typesError = const AppException(AppErrorCode.serverActivitiesFetchFailed);
  }

  @override
  Future<Object?> fetchActivityListEnvelope({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) async {
    listCalls++;
    listRequests.add((query: query, page: page, pageSize: pageSize));
    final error = listError;
    if (error != null) throw error;
    return listEnvelope;
  }

  @override
  Future<Object?> fetchActivityTypesEnvelope() async {
    typesCalls++;
    final error = typesError;
    if (error != null) throw error;
    return typesEnvelope;
  }

  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) => throw UnimplementedError();

  @override
  Future<List<int>> fetchActivityTypes() => throw UnimplementedError();

  @override
  Future<ServerActivity> fetchDetail(int activityId) async {
    detailCalls++;
    return ApiServerActivitiesRepository.parseActivityListEnvelope(
      envelope: _listEnvelope(const [_runRow], 1),
      page: 1,
      pageSize: 20,
    ).items.single;
  }

  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) async {
    routeCalls++;
    return const [ServerRoutePoint(latitude: 1, longitude: 2)];
  }

  @override
  Future<List<ServerActivityGraph>> fetchGraphs(int activityId) async {
    graphsCalls++;
    return const [];
  }

  @override
  Future<List<ServerActivityLap>> fetchLaps(int activityId) async {
    lapsCalls++;
    return const [];
  }
}

void main() {
  late _FakeStore store;
  late _FakeRawSource inner;
  late ConnectionProfile? profile;
  DateTime now = DateTime.utc(2026, 10, 25, 9);

  CachedServerActivitiesRepository makeRepository() =>
      CachedServerActivitiesRepository(
        inner: inner,
        cacheStore: store,
        connectionProfile: () async => profile,
        clock: () => now,
      );

  setUp(() {
    store = _FakeStore();
    inner = _FakeRawSource();
    inner.listEnvelope = _listEnvelope(const [_runRow], 1);
    profile = _profileA;
    now = DateTime.utc(2026, 10, 25, 9);
  });

  test('a successful fetch stores the raw envelope for the identity', () async {
    final repository = makeRepository();

    final page = await repository.fetchPage(
      query: const ServerActivityQuery(search: 'run'),
      page: 2,
      pageSize: 50,
    );

    expect(page.items.single.id, 1);
    expect(page.page, 2);
    expect(page.pageSize, 50);
    expect(page.total, 1);
    final entry = store.entries.values.single;
    expect(entry.profileId, _profileA.id);
    expect(entry.concept, 'activity-list');
    expect(entry.payload, _listEnvelope(const [_runRow], 1));
    expect(entry.fetchedAt, DateTime.utc(2026, 10, 25, 9));
    expect(
      entry.query,
      canonicalCacheQuery(
        ApiServerActivitiesRepository.activityListQueryParameters(
          query: const ServerActivityQuery(search: 'run'),
          page: 2,
          pageSize: 50,
        ),
      ),
    );
  });

  test('a live result carries no cache provenance', () async {
    final repository = makeRepository();

    final page = await repository.fetchPage();

    expect(repository.provenanceOf(page), isNull);
  });

  test('every successful fetch refreshes the cached copy', () async {
    final repository = makeRepository();
    await repository.fetchPage();
    inner.listEnvelope = _listEnvelope(const [_rideRow], 2);
    now = DateTime.utc(2026, 10, 25, 10);

    await repository.fetchPage();

    expect(
      store.entries.values.single.payload,
      _listEnvelope(const [_rideRow], 2),
    );
    expect(
      store.entries.values.single.fetchedAt,
      DateTime.utc(2026, 10, 25, 10),
    );
  });

  test('a network failure falls back to the cached payload', () async {
    final repository = makeRepository();
    await repository.fetchPage();
    inner.goOffline();
    inner.listEnvelope = null;

    final page = await repository.fetchPage();

    expect(inner.listCalls, 2);
    expect(page.items.single.name, 'Morning run');
    final provenance = repository.provenanceOf(page);
    expect(provenance, isNotNull);
    expect(provenance!.fetchedAt, DateTime.utc(2026, 10, 25, 9));
  });

  test('a request timeout falls back to the cached payload', () async {
    final repository = makeRepository();
    await repository.fetchPage();
    inner.listError = const AppException(AppErrorCode.requestTimeout);

    final page = await repository.fetchPage();

    expect(page.items.single.name, 'Morning run');
    expect(repository.provenanceOf(page), isNotNull);
  });

  test(
    'a cached page is only served for its own query, page, and size',
    () async {
      final repository = makeRepository();
      await repository.fetchPage();
      inner.goOffline();

      await expectLater(
        repository.fetchPage(page: 2),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        repository.fetchPage(pageSize: 50),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        repository.fetchPage(query: const ServerActivityQuery(search: 'ride')),
        throwsA(isA<AppException>()),
      );
    },
  );

  test('cached data of another identity is never served', () async {
    final repository = makeRepository();
    await repository.fetchPage();
    profile = _profileB;
    inner.goOffline();

    await expectLater(repository.fetchPage(), throwsA(isA<AppException>()));
    expect(store.entries.values.single.profileId, _profileA.id);
  });

  test('without a cached copy the fetch failure surfaces', () async {
    final repository = makeRepository();
    inner.goOffline();

    await expectLater(repository.fetchPage(), throwsA(isA<AppException>()));
  });

  test('session and authentication failures never fall back', () async {
    final repository = makeRepository();
    await repository.fetchPage();

    for (final code in [
      AppErrorCode.sessionExpired,
      AppErrorCode.notAuthenticated,
      AppErrorCode.unexpectedResponseFormat,
      AppErrorCode.transientAuthUnavailable,
    ]) {
      inner.listError = AppException(code);
      await expectLater(
        repository.fetchPage(),
        throwsA(
          isA<AppException>().having((error) => error.code, 'code', code),
        ),
      );
    }
  });

  test('an HTTP error status never falls back', () async {
    final repository = makeRepository();
    await repository.fetchPage();
    inner.listError = const AppException(
      AppErrorCode.serverActivitiesFetchFailed,
      statusCode: 500,
    );

    await expectLater(
      repository.fetchPage(),
      throwsA(
        isA<AppException>().having((error) => error.statusCode, 'status', 500),
      ),
    );
  });

  test(
    'guest mode behaves like the inner repository and never reads the cache',
    () async {
      final repository = makeRepository();
      await repository.fetchPage();
      profile = null;
      inner.listError = const AppException(AppErrorCode.notAuthenticated);
      store.readCalls = 0;

      await expectLater(
        repository.fetchPage(),
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

  test('activity types are written through and served offline', () async {
    final repository = makeRepository();

    final types = await repository.fetchActivityTypes();

    expect(types, [1, 4]);
    expect(repository.provenanceOf(types), isNull);
    final entry = store.entries.values.single;
    expect(entry.concept, 'activity-types');
    expect(entry.query, '');
    expect(entry.payload, const {'1': 'Run', '4': 'Ride'});

    inner.goOffline();
    inner.typesEnvelope = null;
    final cachedTypes = await repository.fetchActivityTypes();
    expect(cachedTypes, [1, 4]);
    expect(
      repository.provenanceOf(cachedTypes)!.fetchedAt,
      DateTime.utc(2026, 10, 25, 9),
    );
  });

  test(
    'detail, route, graphs, and laps pass through to the inner repository',
    () async {
      final repository = makeRepository();

      await repository.fetchDetail(1);
      await repository.fetchRoute(1);
      await repository.fetchGraphs(1);
      await repository.fetchLaps(1);

      expect(inner.detailCalls, 1);
      expect(inner.routeCalls, 1);
      expect(inner.graphsCalls, 1);
      expect(inner.lapsCalls, 1);
      expect(store.entries, isEmpty);
    },
  );
}
