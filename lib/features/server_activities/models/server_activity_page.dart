import 'package:endurain/features/server_activities/models/server_activity.dart';

class ServerActivityPage {
  ServerActivityPage({
    required List<ServerActivity> items,
    required this.page,
    required this.pageSize,
    required this.total,
  }) : items = List.unmodifiable(items);

  final List<ServerActivity> items;
  final int page;
  final int pageSize;
  final int total;
  bool get hasMore => page * pageSize < total;
}
