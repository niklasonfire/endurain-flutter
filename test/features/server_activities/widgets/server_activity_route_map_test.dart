import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/widgets/server_activity_route_map.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget app(List<ServerRoutePoint> route) => MaterialApp(
    home: Scaffold(
      body: ServerActivityRouteMap(
        route: route,
        tileServerUrl: 'https://tiles.example/{z}/{x}/{y}.png',
        startLabel: 'Start',
        finishLabel: 'Finish',
      ),
    ),
  );

  testWidgets(
    'effort highlight uses the short dateline crossing and respects gaps',
    (tester) async {
      final start = DateTime.utc(2026);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServerActivityRouteMap(
              route: [
                ServerRoutePoint(latitude: 0, longitude: 179.999, time: start),
                ServerRoutePoint(
                  latitude: 0,
                  longitude: -179.999,
                  time: start.add(const Duration(seconds: 10)),
                ),
                ServerRoutePoint(
                  latitude: 1,
                  longitude: -179.999,
                  startsSegment: true,
                  time: start.add(const Duration(seconds: 20)),
                ),
                ServerRoutePoint(
                  latitude: 1.001,
                  longitude: -179.999,
                  time: start.add(const Duration(seconds: 30)),
                ),
              ],
              tileServerUrl: 'https://tiles.example/{z}/{x}/{y}.png',
              startLabel: 'Start',
              finishLabel: 'Finish',
              effortStart: start.add(const Duration(seconds: 5)),
              effortEnd: start.add(const Duration(seconds: 25)),
            ),
          ),
        ),
      );
      await tester.pump();
      final lines = tester
          .widget<PolylineLayer>(find.byType(PolylineLayer))
          .polylines;
      expect(lines, hasLength(4));
      expect(lines[2].points.first.longitude.abs(), closeTo(180, 0.000001));
      expect(lines[2].points.last.latitude, 0);
      expect(lines[3].points.first.latitude, 1);
    },
  );

  testWidgets('highlights only the effort and interpolates exact boundaries', (
    tester,
  ) async {
    final start = DateTime.utc(2026);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ServerActivityRouteMap(
            route: [
              ServerRoutePoint(latitude: 52, longitude: 13, time: start),
              ServerRoutePoint(
                latitude: 52.01,
                longitude: 13.01,
                time: start.add(const Duration(seconds: 10)),
              ),
              ServerRoutePoint(
                latitude: 52.02,
                longitude: 13.02,
                time: start.add(const Duration(seconds: 20)),
              ),
            ],
            tileServerUrl: 'https://tiles.example/{z}/{x}/{y}.png',
            startLabel: 'Start',
            finishLabel: 'Finish',
            effortStart: start.add(const Duration(seconds: 5)),
            effortEnd: start.add(const Duration(seconds: 15)),
          ),
        ),
      ),
    );
    await tester.pump();
    final lines = tester
        .widget<PolylineLayer>(find.byType(PolylineLayer))
        .polylines;
    expect(lines, hasLength(2));
    expect(lines.last.points.first.latitude, closeTo(52.005, 0.000001));
    expect(lines.last.points.last.latitude, closeTo(52.015, 0.000001));
  });

  testWidgets(
    'route is interactive, fits its bounds and preserves GPS gaps with configured tiles',
    (tester) async {
      await tester.pumpWidget(
        app(const [
          ServerRoutePoint(latitude: 52, longitude: 13),
          ServerRoutePoint(latitude: 52.01, longitude: 13.01),
          ServerRoutePoint(latitude: 53, longitude: 14, startsSegment: true),
          ServerRoutePoint(latitude: 53.01, longitude: 14.01),
        ]),
      );
      await tester.pump();
      final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(
        map.options.interactionOptions.flags & InteractiveFlag.drag,
        isNonZero,
      );
      expect(
        map.options.interactionOptions.flags & InteractiveFlag.pinchZoom,
        isNonZero,
      );
      expect(map.options.initialCameraFit, isNotNull);
      expect(
        tester.widget<TileLayer>(find.byType(TileLayer)).urlTemplate,
        'https://tiles.example/{z}/{x}/{y}.png',
      );
      final lines = tester
          .widget<PolylineLayer>(find.byType(PolylineLayer))
          .polylines;
      expect(lines, hasLength(2));
      expect(lines.first.points.last.latitude, 52.01);
      expect(lines.last.points.first.latitude, 53);
      expect(
        tester.widget<MarkerLayer>(find.byType(MarkerLayer)).markers,
        hasLength(2),
      );
      expect(find.byTooltip('Start'), findsOneWidget);
      expect(find.byTooltip('Finish'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'long track and repeated positions render safely; invalid samples never bridge',
    (tester) async {
      final route = List<ServerRoutePoint>.generate(
        12000,
        (i) => ServerRoutePoint(latitude: 52 + i / 100000, longitude: 13),
      );
      await tester.pumpWidget(app(route));
      await tester.pump();
      expect(
        tester
            .widget<PolylineLayer>(find.byType(PolylineLayer))
            .polylines
            .single
            .points,
        hasLength(12000),
      );
      await tester.pumpWidget(
        app(const [
          ServerRoutePoint(latitude: 52, longitude: 13),
          ServerRoutePoint(latitude: 52, longitude: 13),
        ]),
      );
      await tester.pump();
      expect(
        tester
            .widget<FlutterMap>(find.byType(FlutterMap))
            .options
            .initialCameraFit,
        isNull,
      );
      await tester.pumpWidget(
        app(const [
          ServerRoutePoint(latitude: 52, longitude: 13),
          ServerRoutePoint(latitude: double.nan, longitude: 13),
          ServerRoutePoint(latitude: 54, longitude: 14),
        ]),
      );
      await tester.pump();
      expect(
        tester.widget<PolylineLayer>(find.byType(PolylineLayer)).polylines,
        isEmpty,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(app([]));
      expect(find.byType(FlutterMap), findsNothing);
    },
  );
}
