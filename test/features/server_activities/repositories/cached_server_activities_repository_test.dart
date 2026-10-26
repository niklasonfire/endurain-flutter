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

final _routeStream = {
  'stream_type': 7,
  'activity_id': 1,
  'stream_waypoints': [
    {'lat': 52, 'lon': 13},
  ],
};

final _lapsEnvelope = {
  'items': [
    {
      'activity_id': 1,
      'total_distance': 1000,
      'total_timer_time': 300,
      'enhanced_avg_speed': 3,
      'avg_heart_rate': 120,
      'intensity': 'active',
    },
  ],
};

const _hrStreamRow = {
  'activity_id': 7,
  'stream_type': 1,
  'stream_waypoints': [
    {'time': '2026-10-18T10:00:00Z', 'hr': 123},
  ],
};

const _lapRow = {
  'activity_id': 7,
  'total_distance': 1000,
  'total_timer_time': 300,
  'avg_heart_rate': 145,
};

Object? _detailEnvelope(List<Map<String, Object?>> rows) => {
  'items': rows,
  'total': rows.length,
  'page': 1,
  'num_records': 200,
  'next': null,
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

class _FakeRawSource implements ServerActivitiesRawSource {
  Object? listEnvelope;
  Object? typesEnvelope = const {'1': 'Run', '4': 'Ride'};
  Object? detailEnvelope;
  Object? routeEnvelope;
  Object? streamsEnvelope;
  Object? lapsEnvelope;

  /// Error thrown by the envelope fetches, simulating a fetch failure
  /// (network, session, format, ...).
  AppException? listError;
  AppException? typesError;
  AppException? detailError;
  AppException? routeError;
  AppException? streamsError;
  AppException? lapsError;

  int listCalls = 0;
  int typesCalls = 0;
  int detailCalls = 0;
  int routeCalls = 0;
  int streamsCalls = 0;
  int lapsCalls = 0;
  final listRequests =
      <({ServerActivityQuery query, int page, int pageSize})>[];

  /// Invoked when the list envelope fetch starts, letting a test simulate an
  /// account switch while the request is in flight.
  void Function()? onListEnvelopeFetch;

  void goOffline() {
    listError = const AppException(AppErrorCode.serverActivitiesFetchFailed);
    typesError = const AppException(AppErrorCode.serverActivitiesFetchFailed);
    detailError = const AppException(AppErrorCode.serverActivitiesFetchFailed);
    routeError = const AppException(AppErrorCode.serverActivitiesFetchFailed);
    streamsError = const AppException(AppErrorCode.serverActivitiesFetchFailed);
    lapsError = const AppException(AppErrorCode.serverActivitiesFetchFailed);
  }

  @override
  Future<Object?> fetchActivityListEnvelope({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) async {
    listCalls++;
    listRequests.add((query: query, page: page, pageSize: pageSize));
    onListEnvelopeFetch?.call();
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
  Future<Object?> fetchDetailEnvelope(int activityId) async {
    detailCalls++;
    final error = detailError;
    if (error != null) throw error;
    return detailEnvelope;
  }

  @override
  Future<Object?> fetchRouteStreamEnvelope(int activityId) async {
    routeCalls++;
    final error = routeError;
    if (error != null) throw error;
    return routeEnvelope;
  }

  @override
  Future<Object?> fetchActivityStreamsEnvelope(int activityId) async {
    streamsCalls++;
    final error = streamsError;
    if (error != null) throw error;
    return streamsEnvelope;
  }

  @override
  Future<Object?> fetchActivityLapsEnvelope(int activityId) async {
    lapsCalls++;
    final error = lapsError;
    if (error != null) throw error;
    return lapsEnvelope;
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
  Future<ServerActivity> fetchDetail(int activityId) =>
      throw UnimplementedError();

  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) =>
      throw UnimplementedError();

  @override
  Future<List<ServerActivityGraph>> fetchGraphs(int activityId) =>
      throw UnimplementedError();

  @override
  Future<List<ServerActivityLap>> fetchLaps(int activityId) =>
      throw UnimplementedError();
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

  test(
    'a failing cache write never turns a successful live fetch into an error',
    () async {
      final repository = makeRepository();
      store.failWrites = true;

      final page = await repository.fetchPage();

      expect(page.items.single.name, 'Morning run');
      expect(repository.provenanceOf(page), isNull);
      expect(store.entries, isEmpty);
    },
  );

  test(
    'a failing cache read lets the original fetch failure surface',
    () async {
      final repository = makeRepository();
      await repository.fetchPage();
      inner.goOffline();
      inner.listEnvelope = null;
      store.failReads = true;

      await expectLater(
        repository.fetchPage(),
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
    inner.onListEnvelopeFetch = () => profile = _profileB;

    final page = await repository.fetchPage();

    expect(page.items.single.name, 'Morning run');
    expect(store.entries, isEmpty);
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

  test('activity detail is written through and served offline', () async {
    final repository = makeRepository();
    inner.detailEnvelope = _runRow;

    final activity = await repository.fetchDetail(1);

    expect(activity.id, 1);
    expect(activity.name, 'Morning run');
    expect(repository.provenanceOf(activity), isNull);
    final entry = store.entries.values.single;
    expect(entry.profileId, _profileA.id);
    expect(entry.concept, 'activity-detail:1');
    expect(entry.query, '');
    expect(entry.payload, _runRow);
    expect(entry.fetchedAt, DateTime.utc(2026, 10, 25, 9));

    inner.goOffline();
    inner.detailEnvelope = null;
    final cached = await repository.fetchDetail(1);

    expect(inner.detailCalls, 2);
    expect(cached.name, 'Morning run');
    expect(
      repository.provenanceOf(cached)!.fetchedAt,
      DateTime.utc(2026, 10, 25, 9),
    );
  });

  test(
    'a detail never fetched while online surfaces the fetch failure',
    () async {
      final repository = makeRepository();
      inner.goOffline();

      await expectLater(
        repository.fetchDetail(1),
        throwsA(isA<AppException>()),
      );
      expect(store.readCalls, 1);
      expect(store.entries, isEmpty);
    },
  );

  test('cached detail of another identity is never served', () async {
    final repository = makeRepository();
    inner.detailEnvelope = _runRow;
    await repository.fetchDetail(1);
    profile = _profileB;
    inner.goOffline();

    await expectLater(repository.fetchDetail(1), throwsA(isA<AppException>()));
    expect(store.entries.values.single.profileId, _profileA.id);
  });

  test(
    'session and authentication failures on detail never fall back',
    () async {
      final repository = makeRepository();
      inner.detailEnvelope = _runRow;
      await repository.fetchDetail(1);

      for (final code in [
        AppErrorCode.sessionExpired,
        AppErrorCode.notAuthenticated,
      ]) {
        inner.detailError = AppException(code);
        await expectLater(
          repository.fetchDetail(1),
          throwsA(
            isA<AppException>().having((error) => error.code, 'code', code),
          ),
        );
      }
    },
  );

  test(
    'the route is written through and the no-route state is cached',
    () async {
      final repository = makeRepository();
      inner.routeEnvelope = _routeStream;

      final route = await repository.fetchRoute(1);

      expect(route, hasLength(1));
      var entry = store.entries.values.single;
      expect(entry.concept, 'activity-route:1');
      expect(entry.query, '');
      expect(entry.payload, _routeStream);
      expect(repository.provenanceOf(route), isNull);

      // A GPS-less activity answers 404; the empty route caches like any
      // success, so it degrades to "no route" offline instead of an error.
      inner.routeEnvelope = null;
      expect(await repository.fetchRoute(1), isEmpty);
      entry = store.entries.values.single;
      expect(entry.payload, isNull);

      inner.goOffline();
      final cached = await repository.fetchRoute(1);

      expect(inner.routeCalls, 3);
      expect(cached, isEmpty);
      expect(
        repository.provenanceOf(cached)!.fetchedAt,
        DateTime.utc(2026, 10, 25, 9),
      );
    },
  );

  test('laps are written through and served offline', () async {
    final repository = makeRepository();
    inner.lapsEnvelope = _lapsEnvelope;

    final laps = await repository.fetchLaps(1);

    expect(laps.single.distanceMeters, 1000);
    expect(laps.single.heartRate, 120);
    expect(repository.provenanceOf(laps), isNull);
    final entry = store.entries.values.single;
    expect(entry.concept, 'activity-laps:1');
    expect(
      entry.query,
      canonicalCacheQuery(const {'page_number': '1', 'num_records': '200'}),
    );
    expect(entry.payload, _lapsEnvelope);

    inner.goOffline();
    final cached = await repository.fetchLaps(1);

    expect(inner.lapsCalls, 2);
    expect(cached.single.distanceMeters, 1000);
    expect(
      repository.provenanceOf(cached)!.fetchedAt,
      DateTime.utc(2026, 10, 25, 9),
    );
  });

  test('laps are written through and served offline with provenance', () async {
    final repository = makeRepository();
    inner.lapsEnvelope = _detailEnvelope(const [_lapRow]);

    final laps = await repository.fetchLaps(7);

    expect(laps.single.distanceMeters, 1000);
    expect(repository.provenanceOf(laps), isNull);
    final entry = store.entries.values.single;
    expect(entry.concept, 'activity-laps:7');
    expect(entry.payload, _detailEnvelope(const [_lapRow]));

    inner.goOffline();
    inner.lapsEnvelope = null;
    final cachedLaps = await repository.fetchLaps(7);
    expect(cachedLaps.single.heartRate, 145);
    expect(
      repository.provenanceOf(cachedLaps)!.fetchedAt,
      DateTime.utc(2026, 10, 25, 9),
    );
  });

  test(
    'a successful graph fetch stores the raw streams envelope for the activity',
    () async {
      final repository = makeRepository();
      inner.streamsEnvelope = _detailEnvelope(const [_hrStreamRow]);

      final graphs = await repository.fetchGraphs(7);

      expect(graphs.single.metric, ServerGraphMetric.heartRate);
      expect(graphs.single.points().single.value, 123);
      expect(repository.provenanceOf(graphs), isNull);
      final entry = store.entries.values.single;
      expect(entry.profileId, _profileA.id);
      expect(entry.concept, 'activity-streams:7');
      expect(entry.payload, _detailEnvelope(const [_hrStreamRow]));
      expect(entry.fetchedAt, DateTime.utc(2026, 10, 25, 9));
      expect(
        entry.query,
        canonicalCacheQuery(const {'page_number': '1', 'num_records': '200'}),
      );
    },
  );

  test(
    'graph fetches offline fall back to the cached envelope with provenance',
    () async {
      final repository = makeRepository();
      inner.streamsEnvelope = _detailEnvelope(const [_hrStreamRow]);
      await repository.fetchGraphs(7);
      inner.goOffline();
      inner.streamsEnvelope = null;

      final graphs = await repository.fetchGraphs(7);

      expect(inner.streamsCalls, 2);
      expect(graphs.single.metric, ServerGraphMetric.heartRate);
      expect(graphs.single.points().single.value, 123);
      expect(
        repository.provenanceOf(graphs)!.fetchedAt,
        DateTime.utc(2026, 10, 25, 9),
      );
    },
  );

  test('every successful graph fetch refreshes the cached copy', () async {
    final repository = makeRepository();
    inner.streamsEnvelope = _detailEnvelope(const [_hrStreamRow]);
    await repository.fetchGraphs(7);
    now = DateTime.utc(2026, 10, 25, 10);

    await repository.fetchGraphs(7);

    expect(
      store.entries.values.single.fetchedAt,
      DateTime.utc(2026, 10, 25, 10),
    );
  });

  test(
    'cached graphs are never served for another activity or identity',
    () async {
      final repository = makeRepository();
      inner.streamsEnvelope = _detailEnvelope(const [_hrStreamRow]);
      await repository.fetchGraphs(7);
      inner.goOffline();

      await expectLater(
        repository.fetchGraphs(8),
        throwsA(isA<AppException>()),
      );
      profile = _profileB;
      await expectLater(
        repository.fetchGraphs(7),
        throwsA(isA<AppException>()),
      );
    },
  );

  test('graph failures other than being unreachable never fall back', () async {
    final repository = makeRepository();
    inner.streamsEnvelope = _detailEnvelope(const [_hrStreamRow]);
    await repository.fetchGraphs(7);

    inner.streamsError = const AppException(AppErrorCode.sessionExpired);
    await expectLater(
      repository.fetchGraphs(7),
      throwsA(
        isA<AppException>().having(
          (error) => error.code,
          'code',
          AppErrorCode.sessionExpired,
        ),
      ),
    );
    inner.streamsError = const AppException(
      AppErrorCode.serverActivitiesFetchFailed,
      statusCode: 500,
    );
    await expectLater(
      repository.fetchGraphs(7),
      throwsA(
        isA<AppException>().having((error) => error.statusCode, 'status', 500),
      ),
    );
  });

  test(
    'graphs and laps never fetched online degrade to the fetch failure',
    () async {
      final repository = makeRepository();
      inner.goOffline();

      await expectLater(
        repository.fetchGraphs(7),
        throwsA(isA<AppException>()),
      );
      await expectLater(repository.fetchLaps(7), throwsA(isA<AppException>()));
      expect(store.entries, isEmpty);
    },
  );

  test('guest mode never reads the graph cache', () async {
    final repository = makeRepository();
    inner.streamsEnvelope = _detailEnvelope(const [_hrStreamRow]);
    await repository.fetchGraphs(7);
    profile = null;
    inner.streamsError = const AppException(AppErrorCode.notAuthenticated);
    store.readCalls = 0;

    await expectLater(
      repository.fetchGraphs(7),
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
}
