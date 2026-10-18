import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';

/// Authenticated, read-only view of the active server account. Each operation
/// rejects its response if the active connection changes while it is loading.
abstract interface class ServerActivitiesRepository {
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  });
  Future<List<int>> fetchActivityTypes();
  Future<ServerActivity> fetchDetail(int activityId);
  Future<List<ServerRoutePoint>> fetchRoute(int activityId);
}
