import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:endurain/features/server_activities/repositories/server_activity_graph_repository.dart';

import 'dart:async';

import 'package:endurain/features/server_activities/controllers/server_activity_detail_controller.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'graphs and laps retry independently and clear on account change',
    () async {
      final connection = ValueNotifier<String?>('a');
      final repository = _GraphRepository();
      final controller = ServerActivityDetailController(
        activityId: 1,
        repository: repository,
        connection: connection,
      );
      final loading = controller.load();
      repository.details.complete(
        const ServerActivity(id: 1, name: 'Run', activityType: 1),
      );
      repository.routes.single.complete(const []);
      repository.graphRequests.single.completeError(Exception('offline'));
      repository.lapRequests.single.complete(const []);
      await loading;
      expect(controller.graphError, isNotNull);
      expect(controller.lapError, isNull);
      final retry = controller.loadGraphs();
      final graph = ServerActivityGraph.fromJson({
        'stream_type': 1,
        'stream_waypoints': [
          {'hr': 120},
        ],
      });
      repository.graphRequests.last.complete([graph]);
      await retry;
      expect(controller.graphs, [graph]);
      expect(repository.lapRequests, hasLength(1));
      final pending = controller.loadLaps();
      connection.value = null;
      expect(controller.graphs, isEmpty);
      repository.lapRequests.last.complete([
        const ServerActivityLap(
          distanceMeters: 1000,
          seconds: 300,
          speed: 3,
          heartRate: 120,
          isRest: false,
        ),
      ]);
      await pending;
      expect(controller.laps, isEmpty);
      controller.dispose();
      connection.dispose();
    },
  );

  test(
    'detail remains visible when route fails and route can retry alone',
    () async {
      final connection = ValueNotifier<String?>('a');
      final repository = _Repository();
      final controller = ServerActivityDetailController(
        activityId: 1,
        repository: repository,
        connection: connection,
      );
      final loading = controller.load();
      repository.details.complete(
        const ServerActivity(id: 1, name: 'Run', activityType: 1),
      );
      repository.routes.first.completeError(Exception('offline'));
      await loading;
      expect(controller.activity?.name, 'Run');
      expect(controller.error, isNull);
      expect(controller.routeError, isNotNull);
      final retry = controller.loadRoute();
      repository.routes.last.complete(const [
        ServerRoutePoint(latitude: 52, longitude: 13),
      ]);
      await retry;
      expect(controller.route, hasLength(1));
      expect(controller.routeError, isNull);
      expect(repository.detailCalls, 1);
      controller.dispose();
      connection.dispose();
    },
  );

  test('switching account clears detail and rejects pending route without loading same id for new account', () async {
    final connection = ValueNotifier<String?>('a');
    final repository = _Repository();
    final controller = ServerActivityDetailController(
      activityId: 1,
      repository: repository,
      connection: connection,
    );
    final loading = controller.load();
    repository.details.complete(
      const ServerActivity(id: 1, name: 'Private', activityType: 1),
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.activity?.name, 'Private');
    connection.value = 'b';
    expect(controller.activity, isNull);
    expect(controller.isAccountChanged, isTrue);
    repository.routes.first.complete(const [
      ServerRoutePoint(latitude: 52, longitude: 13),
    ]);
    await loading;
    await controller.load();
    expect(controller.route, isEmpty);
    expect(repository.detailCalls, 1);
    controller.dispose();
    connection.dispose();
  });
  test('cached graph and lap results surface their cache provenance', () async {
    final connection = ValueNotifier<String?>('a');
    final repository = _CachedGraphRepository();
    final controller = ServerActivityDetailController(
      activityId: 1,
      repository: repository,
      connection: connection,
    );
    final loading = controller.load();
    repository.details.complete(
      const ServerActivity(id: 1, name: 'Run', activityType: 1),
    );
    repository.routes.single.complete(const []);
    final graphs = [
      ServerActivityGraph.fromJson({
        'stream_type': 1,
        'stream_waypoints': [
          {'hr': 120},
        ],
      }),
    ];
    const laps = [
      ServerActivityLap(
        distanceMeters: 1000,
        seconds: 300,
        speed: 3,
        heartRate: 120,
        isRest: false,
      ),
    ];
    repository.graphRequests.single.complete(graphs);
    repository.lapRequests.single.complete(laps);
    final fetchedAt = DateTime.utc(2026, 10, 25, 9);
    repository.provenance[graphs] = OfflineCacheServeInfo(fetchedAt: fetchedAt);
    repository.provenance[laps] = OfflineCacheServeInfo(fetchedAt: fetchedAt);
    await loading;
    expect(controller.graphError, isNull);
    expect(controller.graphCacheFetchedAt, fetchedAt);
    expect(controller.lapCacheFetchedAt, fetchedAt);

    final reload = controller.loadGraphs();
    final freshGraphs = [
      ServerActivityGraph.fromJson({
        'stream_type': 1,
        'stream_waypoints': [
          {'hr': 125},
        ],
      }),
    ];
    repository.graphRequests.last.complete(freshGraphs);
    await reload;
    expect(controller.graphs, freshGraphs);
    expect(controller.graphCacheFetchedAt, isNull);

    connection.value = null;
    expect(controller.graphCacheFetchedAt, isNull);
    expect(controller.lapCacheFetchedAt, isNull);
    controller.dispose();
    connection.dispose();
  });
}

class _Repository implements ServerActivitiesRepository {
  final details = Completer<ServerActivity>();
  final routes = <Completer<List<ServerRoutePoint>>>[];
  int detailCalls = 0;
  @override
  Future<ServerActivity> fetchDetail(int activityId) {
    detailCalls++;
    return details.future;
  }

  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) {
    final request = Completer<List<ServerRoutePoint>>();
    routes.add(request);
    return request.future;
  }

  @override
  Future<List<int>> fetchActivityTypes() => throw UnimplementedError();
  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) => throw UnimplementedError();
}

class _GraphRepository extends _Repository
    implements ServerActivityGraphRepository {
  final graphRequests = <Completer<List<ServerActivityGraph>>>[];
  final lapRequests = <Completer<List<ServerActivityLap>>>[];
  @override
  Future<List<ServerActivityGraph>> fetchGraphs(int activityId) {
    final request = Completer<List<ServerActivityGraph>>();
    graphRequests.add(request);
    return request.future;
  }

  @override
  Future<List<ServerActivityLap>> fetchLaps(int activityId) {
    final request = Completer<List<ServerActivityLap>>();
    lapRequests.add(request);
    return request.future;
  }
}

class _CachedGraphRepository extends _GraphRepository
    implements OfflineCacheProvenance {
  final provenance = <Object, OfflineCacheServeInfo>{};

  @override
  OfflineCacheServeInfo? provenanceOf(Object result) => provenance[result];
}
