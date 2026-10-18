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
