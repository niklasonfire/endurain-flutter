import 'dart:async';

import 'package:endurain/features/server_activities/controllers/server_activities_controller.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'switching accounts discards an outstanding response and visible data',
    () async {
      final connection = ValueNotifier<String?>('account-a');
      final repository = _Repository();
      final controller = ServerActivitiesController(
        repository: repository,
        connection: connection,
      );
      final first = controller.refresh();
      connection.value = 'account-b';
      repository.requests.first.complete(
        ServerActivityPage(
          items: [
            const ServerActivity(id: 1, activityType: 1, name: 'Private A'),
          ],
          page: 1,
          pageSize: 20,
          total: 1,
        ),
      );
      await first;
      expect(controller.items, isEmpty);
      repository.requests.last.complete(
        ServerActivityPage(
          items: [const ServerActivity(id: 2, activityType: 4, name: 'B')],
          page: 1,
          pageSize: 20,
          total: 1,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.items.single.name, 'B');
      connection.value = null;
      expect(controller.items, isEmpty);
      expect(controller.isGuest, isTrue);
      controller.dispose();
      connection.dispose();
    },
  );
  test('page failures keep loaded rows and retry the same page', () async {
    final connection = ValueNotifier<String?>('account');
    final repository = _Repository();
    final controller = ServerActivitiesController(
      repository: repository,
      connection: connection,
    );
    final initial = controller.refresh();
    repository.requests.last.complete(
      ServerActivityPage(
        items: [const ServerActivity(id: 1, name: 'First', activityType: 1)],
        page: 1,
        pageSize: 1,
        total: 2,
      ),
    );
    await initial;
    final next = controller.loadMore();
    repository.requests.last.completeError(Exception('Offline'));
    await next;
    expect(controller.items.single.name, 'First');
    expect(controller.error, isNull);
    expect(controller.loadMoreError, isNotNull);
    final retry = controller.loadMore();
    repository.requests.last.complete(
      ServerActivityPage(
        items: [const ServerActivity(id: 2, name: 'Second', activityType: 4)],
        page: 2,
        pageSize: 1,
        total: 2,
      ),
    );
    await retry;
    expect(controller.items.map((item) => item.id), [1, 2]);
    expect(repository.pages, [1, 2, 2]);
    expect(controller.hasMore, isFalse);
    expect(controller.loadMoreError, isNull);
    controller.dispose();
    connection.dispose();
  });

  test('changing filters discards the previous search response', () async {
    final connection = ValueNotifier<String?>('account');
    final repository = _Repository();
    final controller = ServerActivitiesController(
      repository: repository,
      connection: connection,
    );
    final previous = controller.refresh();
    final current = controller.setQuery(
      ServerActivityQuery(
        search: 'forest',
        activityType: 12,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      ),
    );
    repository.requests.first.complete(
      ServerActivityPage(
        items: [const ServerActivity(id: 1, name: 'Stale', activityType: 1)],
        page: 1,
        pageSize: 20,
        total: 1,
      ),
    );
    await previous;
    expect(controller.items, isEmpty);
    repository.requests.last.complete(
      ServerActivityPage(
        items: [const ServerActivity(id: 2, name: 'Forest', activityType: 12)],
        page: 1,
        pageSize: 20,
        total: 1,
      ),
    );
    await current;
    expect(repository.queries.last.search, 'forest');
    expect(repository.queries.last.activityType, 12);
    expect(repository.queries.last.endDate, DateTime(2026, 1, 31));
    expect(controller.items.single.name, 'Forest');
    controller.dispose();
    connection.dispose();
  });
  test(
    'route previews share requests and keep at most two requests in flight',
    () async {
      final connection = ValueNotifier<String?>('account');
      final repository = _RouteRepository();
      final controller = ServerActivitiesController(
        repository: repository,
        connection: connection,
      );
      final first = controller.loadRoute(1);
      final duplicate = controller.loadRoute(1);
      final second = controller.loadRoute(2);
      final third = controller.loadRoute(3);
      await Future<void>.delayed(Duration.zero);
      expect(repository.routeIds, [1, 2]);
      repository.routes[1]!.complete(const [
        ServerRoutePoint(latitude: 52, longitude: 13),
      ]);
      expect((await first).single.latitude, 52);
      expect((await duplicate).single.longitude, 13);
      await Future<void>.delayed(Duration.zero);
      expect(repository.routeIds, [1, 2, 3]);
      repository.routes[2]!.complete(const []);
      repository.routes[3]!.complete(const []);
      await Future.wait([second, third]);
      await controller.loadRoute(1);
      expect(repository.routeIds.where((id) => id == 1), hasLength(1));
      controller.dispose();
      connection.dispose();
    },
  );

  test('account changes reject late and queued route previews', () async {
    final connection = ValueNotifier<String?>('a');
    final repository = _RouteRepository();
    final controller = ServerActivitiesController(
      repository: repository,
      connection: connection,
    );
    final first = controller.loadRoute(1),
        second = controller.loadRoute(2),
        queued = controller.loadRoute(3);
    await Future<void>.delayed(Duration.zero);
    connection.value = null;
    repository.routes[1]!.complete(const [
      ServerRoutePoint(latitude: 52, longitude: 13),
    ]);
    repository.routes[2]!.complete(const []);
    expect(await first, isEmpty);
    expect(await second, isEmpty);
    expect(await queued, isEmpty);
    expect(repository.routeIds, [1, 2]);
    controller.dispose();
    connection.dispose();
  });

  test(
    'route preview cache evicts old entries after forty activities',
    () async {
      final connection = ValueNotifier<String?>('account');
      final repository = _ImmediateRoutesRepository();
      final controller = ServerActivitiesController(
        repository: repository,
        connection: connection,
      );
      for (var id = 1; id <= 40; id++) {
        await controller.loadRoute(id);
      }
      await controller.loadRoute(1); // Keep this older entry recently used.
      await controller.loadRoute(41);
      await controller.loadRoute(1);
      await controller.loadRoute(2);
      expect(repository.routeIds.where((id) => id == 1), hasLength(1));
      expect(repository.routeIds.where((id) => id == 2), hasLength(2));
      controller.dispose();
      connection.dispose();
    },
  );
}

class _Repository implements ServerActivitiesRepository {
  final pages = <int>[];
  final queries = <ServerActivityQuery>[];
  final requests = <Completer<ServerActivityPage>>[];
  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) {
    pages.add(page);
    queries.add(query);
    final request = Completer<ServerActivityPage>();
    requests.add(request);
    return request.future;
  }

  @override
  Future<List<int>> fetchActivityTypes() async => [1, 4];
  @override
  Future<ServerActivity> fetchDetail(int activityId) =>
      throw UnimplementedError();
  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) =>
      throw UnimplementedError();
}

class _RouteRepository extends _Repository {
  final routeIds = <int>[];
  final routes = <int, Completer<List<ServerRoutePoint>>>{};
  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) {
    routeIds.add(activityId);
    final result = Completer<List<ServerRoutePoint>>();
    routes[activityId] = result;
    return result.future;
  }
}

class _ImmediateRoutesRepository extends _Repository {
  final routeIds = <int>[];
  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) async {
    routeIds.add(activityId);
    return const [];
  }
}
