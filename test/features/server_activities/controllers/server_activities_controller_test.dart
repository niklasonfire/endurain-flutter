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
