import 'dart:io';
import 'dart:ui' as ui;

import 'package:endurain/core/localization/app_locales.dart';
import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:endurain/features/server_activities/widgets/server_activity_charts.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'paints measured segments while leaving missing readings unjoined',
    (tester) async {
      const color = Color(0xff0055ff);
      const boundaryKey = ValueKey('review-rendering');
      final graph = ServerActivityGraph.fromJson({
        'stream_type': 1,
        'stream_waypoints': [
          {'time': '2026-10-18T10:00:00Z', 'hr': 120},
          {'time': '2026-10-18T10:00:10Z', 'hr': 130},
          {'time': '2026-10-18T10:00:20Z', 'hr': null},
          {'time': '2026-10-18T10:00:30Z', 'hr': 140},
          {'time': '2026-10-18T10:00:40Z', 'hr': 150},
        ],
      });
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              colorScheme: const ColorScheme.light(primary: color),
            ),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  child: ServerActivityChart(graph: graph, activityType: 1),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final area = tester.getRect(
        find.byKey(const ValueKey('chart-heartRate')),
      );
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(boundaryKey),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final pixels = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        int plottedPixels(double from, double to) {
          var count = 0;
          for (var y = area.top.ceil(); y < area.bottom.floor(); y++) {
            for (
              var x = (area.left + area.width * from).ceil();
              x < (area.left + area.width * to).floor();
              x++
            ) {
              final offset = (y * image.width + x) * 4;
              if (pixels.getUint8(offset) == 0 &&
                  pixels.getUint8(offset + 1) == 85 &&
                  pixels.getUint8(offset + 2) == 255) {
                count++;
              }
            }
          }
          return count;
        }

        expect(plottedPixels(0, 0.25), greaterThan(40));
        expect(plottedPixels(0.75, 1), greaterThan(40));
        expect(plottedPixels(0.35, 0.65), 0);
        expect(tester.takeException(), isNull);
        final output = Platform.environment['ENDURAIN_REVIEW_IMAGE'];
        if (output != null) {
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(output).writeAsBytes(png!.buffer.asUint8List());
        }
        image.dispose();
      });
    },
  );
}
