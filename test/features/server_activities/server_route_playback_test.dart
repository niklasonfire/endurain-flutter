import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime.utc(2026, 10, 18, 10);
  ServerRoutePoint point(int seconds, {bool gap = false}) => ServerRoutePoint(
    latitude: 52 + seconds / 1000,
    longitude: 13,
    time: start.add(Duration(seconds: seconds)),
    startsSegment: gap,
  );

  test('playback uses absolute timestamps and handles boundaries and gaps', () {
    final first = point(0);
    final second = point(10);
    final afterGap = point(20, gap: true);
    final route = ServerRoutePlayback([
      first,
      second,
      afterGap,
      point(40),
      point(180),
    ]);
    expect(route.at(start), same(first));
    expect(route.at(start.add(const Duration(seconds: 8))), same(second));
    expect(route.at(start.add(const Duration(seconds: 15))), isNull);
    expect(route.at(start.add(const Duration(seconds: 20))), same(afterGap));
    expect(route.at(start.add(const Duration(seconds: 30))), isNull);
    expect(route.at(start.add(const Duration(seconds: 100))), isNull);
    expect(route.at(start.subtract(const Duration(seconds: 1))), isNull);
    expect(route.at(start.add(const Duration(seconds: 181))), isNull);
    expect(route.at(null), isNull);
    expect(
      ServerRoutePlayback(const [ServerRoutePoint(latitude: 52, longitude: 13)])
          .at(start),
      isNull,
    );
  });

  test(
    'pace conversion and envelope sampling preserve actual sample timestamps',
    () {
      final graph = ServerActivityGraph.fromJson({
        'stream_type': 5,
        'stream_waypoints': List.generate(
          2000,
          (i) => {
            'time': start.add(Duration(seconds: i + 10)).toIso8601String(),
            'vel': 3,
          },
        ),
      }).paceFromSpeed();
      expect(graph.xAt(start.add(const Duration(seconds: 20))), 10);
      expect(graph.nearest(10)!.time, start.add(const Duration(seconds: 20)));
      for (final p in graph.points(budget: 50)) {
        expect(p.time, start.add(Duration(seconds: p.x.toInt() + 10)));
      }
    },
  );
}
