import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('large streams preserve peaks and gaps with bounded painting and exact readout', () {
    final graph = ServerActivityGraph.fromJson({
      'stream_type': 1,
      'stream_waypoints': List.generate(
        100000,
        (index) => {
          'hr': index == 54321
              ? 220
              : index == 12345
              ? null
              : 120,
        },
      ),
    });
    final points = graph.points();
    expect(points.length, lessThanOrEqualTo(1200));
    expect(points.any((point) => point.value == 220), isTrue);
    expect(points.any((point) => point.value == null), isTrue);
    expect(graph.nearest(54321)?.value, 220);
    expect(graph.nearest(12345)?.value, isNull);
    expect(points.last.x, 99999);
  });

  test('unknown time falls back explicitly to sample numbers without fake distance', () {
    final graph = ServerActivityGraph.fromJson({
      'stream_type': 6,
      'stream_waypoints': [
        {'time': '2026-10-18T10:00:00Z', 'pace': 0.3},
        {'time': null, 'pace': 0},
        {'time': 'invalid', 'pace': -1},
      ],
    });
    expect(graph.hasTimeAxis, isFalse);
    expect(graph.points().map((point) => point.x), [0, 1, 2]);
    expect(graph.points().map((point) => point.value), [0.3, null, null]);
  });

  test('uses real UTC sample times and retains measurement gaps', () {
    final graph = ServerActivityGraph.fromJson({
      'stream_type': 1,
      'stream_waypoints': [
        {'time': '2026-10-18T10:00:00', 'hr': 120},
        {'time': '2026-10-18T12:00:10+02:00', 'hr': null},
        {'time': '2026-10-18T10:00:20Z', 'hr': 140},
        {'time': '2026-10-18T10:05:00Z', 'hr': 150},
      ],
    });
    final points = graph.points();
    expect(graph.hasTimeAxis, isTrue);
    expect(points.map((p) => p.x), [0, 10, 20, 300]);
    expect(points[1].value, isNull);
    expect(points.last.startsSegment, isTrue);
  });
}
