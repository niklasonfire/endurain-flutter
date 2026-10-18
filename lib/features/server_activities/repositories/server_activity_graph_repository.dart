import 'package:endurain/features/server_activities/models/server_activity_graph.dart';

/// Optional read-only detail capability, separate from paginated activity data.
abstract interface class ServerActivityGraphRepository {
  Future<List<ServerActivityGraph>> fetchGraphs(int activityId);
  Future<List<ServerActivityLap>> fetchLaps(int activityId);
}
