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
