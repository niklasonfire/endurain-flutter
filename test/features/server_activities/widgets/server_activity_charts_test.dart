import 'package:endurain/core/localization/app_locales.dart';
import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:endurain/features/server_activities/widgets/server_activity_charts.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.localeTestValue =
        const Locale('de', 'DE');
  });
  tearDown(
    () => TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearLocaleTestValue(),
  );
  testWidgets(
    'chart has a real paint area, taps read actual elapsed time and gaps',
    (tester) async {
      final graph = ServerActivityGraph.fromJson({
        'stream_type': 1,
        'stream_waypoints': [
          {'time': '2026-10-18T10:00:00Z', 'hr': 120},
          {'time': '2026-10-18T10:00:10Z', 'hr': null},
          {'time': '2026-10-18T10:00:20Z', 'hr': 150},
        ],
      });
      await tester.pumpWidget(
        _app(ServerActivityChart(graph: graph, activityType: 1)),
      );
      final chart = find.byKey(const ValueKey('chart-heartRate'));
      expect(tester.getSize(chart).height, 160);
      expect(tester.getSize(chart).width, greaterThan(100));
      final box = tester.getRect(chart);
      await tester.tapAt(box.center);
      await tester.pump();
      expect(find.text('0:10 · —'), findsOneWidget);
      await tester.tapAt(Offset(box.right - 2, box.center.dy));
      await tester.pump();
      expect(find.text('0:20 · 150 bpm'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'German dark chart renders a single pace sample and correct min/km',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final graph = ServerActivityGraph.fromJson({
        'stream_type': 6,
        'stream_waypoints': [
          {'pace': 0.3},
        ],
      });
      await tester.pumpWidget(
        _app(ServerActivityChart(graph: graph, activityType: 1), german: true),
      );
      expect(find.text('1 · 5:00 min/km'), findsOneWidget);
      expect(find.text('Messpunktnummer (Zeitstempel fehlen)'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('chart-pace'))).width,
        greaterThan(200),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('pace sport can read pace from a genuine velocity-only stream', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        ServerActivityCharts(
          activityType: 1,
          graphs: [
            ServerActivityGraph.fromJson({
              'stream_type': 5,
              'stream_waypoints': [
                {'vel': 10 / 3},
                {'vel': 0},
              ],
            }),
          ],
        ),
      ),
    );
    expect(find.text('1 · 5:00 min/km'), findsOneWidget);
    expect(find.byKey(const ValueKey('chart-pace')), findsOneWidget);
    expect(find.byKey(const ValueKey('chart-speed')), findsNothing);
  });

  testWidgets('imperial temperature and running cadence follow web units', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
    await tester.pumpWidget(
      _app(
        ServerActivityCharts(
          activityType: 1,
          graphs: [
            ServerActivityGraph.fromJson({
              'stream_type': 8,
              'stream_waypoints': [
                {'temp': 20},
              ],
            }),
            ServerActivityGraph.fromJson({
              'stream_type': 3,
              'stream_waypoints': [
                {'cad': 85},
              ],
            }),
          ],
        ),
      ),
    );
    expect(find.text('1 · 170 spm'), findsOneWidget);
    expect(find.text('1 · 68.0 °F'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'lap expansion reads recorded unequal distances and stationary work is active',
    (tester) async {
      await tester.pumpWidget(
        _app(
          ServerActivityLaps(
            activityType: 1,
            laps: [
              ServerActivityLap.fromJson({
                'total_distance': 1000,
                'total_timer_time': 300,
                'avg_heart_rate': 140,
              }),
              ServerActivityLap.fromJson({
                'total_distance': 400,
                'total_timer_time': 120,
              }),
              ServerActivityLap.fromJson({'total_timer_time': 60}),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Recorded laps (3)'));
      await tester.pumpAndSettle();
      expect(
        find.text('1.00 km · 5:00 · 5:00 min/km · 140 bpm'),
        findsOneWidget,
      );
      expect(find.text('400 m · 2:00 · 5:00 min/km'), findsOneWidget);
      expect(find.text('Lap 3'), findsOneWidget);
      expect(find.textContaining('Recovery'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app(Widget child, {bool german = false}) => MaterialApp(
  locale: Locale(german ? 'de' : 'en'),
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: ThemeData(brightness: german ? Brightness.dark : Brightness.light),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
