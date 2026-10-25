import 'package:endurain/core/localization/app_locales.dart';
import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:endurain/features/server_activities/repositories/server_activity_graph_repository.dart';
import 'package:endurain/shared/widgets/cache_last_updated_chip.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:endurain/features/server_activities/controllers/server_activity_detail_controller.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:endurain/features/server_activities/screens/server_activity_detail_screen.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'graph tap and slider move the visible map marker using timestamps',
    (tester) async {
      tester.view.physicalSize = const Size(420, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final connection = ValueNotifier<String?>('a');
      final controller = ServerActivityDetailController(
        activityId: 7,
        repository: _PlaybackRepository(),
        connection: connection,
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ServerActivityDetailScreen(
            activityId: 7,
            controller: controller,
            tileServerUrlProvider: () async =>
                'https://tiles.example/{z}/{x}/{y}.png',
          ),
        ),
      );
      await tester.pumpAndSettle();
      final chart = find.byKey(const ValueKey('chart-heartRate'));
      await tester.scrollUntilVisible(chart, 200);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('route-playback-marker')), findsNothing);
      await tester.tapAt(tester.getRect(chart).center);
      await tester.pump();
      var marker = tester
          .widget<MarkerLayer>(find.byType(MarkerLayer))
          .markers
          .first;
      expect(marker.point.latitude, 52.01);
      expect(marker.point.longitude, 13.01);
      final markerFinder = find.byKey(const ValueKey('route-playback-marker'));
      expect(markerFinder.hitTestable(), findsOneWidget);
      await tester.drag(chart, const Offset(180, 0));
      await tester.pump();
      marker = tester
          .widget<MarkerLayer>(find.byType(MarkerLayer))
          .markers
          .first;
      expect(marker.point.latitude, 52.02);
      // Slider interaction takes the same selection path.
      tester.widget<Slider>(find.byType(Slider)).onChanged!(0);
      await tester.pump();
      marker = tester
          .widget<MarkerLayer>(find.byType(MarkerLayer))
          .markers
          .first;
      expect(marker.point.latitude, 52);
      connection.value = null;
      await tester.pump();
      expect(markerFinder, findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      connection.dispose();
    },
  );

  testWidgets(
    'outdoor metrics survive route failure and retry loads real route',
    (tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('de', 'DE');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      final connection = ValueNotifier<String?>('a');
      final repository = _OutdoorRepository();
      final controller = ServerActivityDetailController(
        activityId: 7,
        repository: repository,
        connection: connection,
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ServerActivityDetailScreen(
            activityId: 7,
            controller: controller,
            tileServerUrlProvider: () async =>
                'https://tiles.example/{z}/{x}/{y}.png',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('River run'), findsOneWidget);
      expect(find.text('5.00 km'), findsOneWidget);
      expect(find.text('5:40 min/km'), findsOneWidget);
      expect(find.text('28:20'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Could not load the route.'),
        150,
      );
      expect(find.text('Could not load the route.'), findsOneWidget);
      await tester.ensureVisible(find.text('Try again'));
      await tester.tap(find.text('Try again'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Could not load the route.'), findsNothing);
      expect(find.byTooltip('Started'), findsOneWidget);
      expect(repository.routeCalls, 2);
      expect(repository.detailCalls, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      connection.dispose();
    },
  );

  testWidgets(
    'indoor details show real metrics without inventing a map and disappear on logout',
    (tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('de', 'DE');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      final connection = ValueNotifier<String?>('a');
      final controller = ServerActivityDetailController(
        activityId: 7,
        repository: _Repository(),
        connection: connection,
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(brightness: Brightness.dark),
          home: ServerActivityDetailScreen(
            activityId: 7,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Indoor training'), findsOneWidget);
      expect(find.text('Real description'), findsOneWidget);
      expect(find.text('30:00'), findsOneWidget);
      expect(find.text('125 bpm'), findsOneWidget);
      expect(find.text('Keine GPS-Strecke verfügbar.'), findsOneWidget);
      connection.value = null;
      await tester.pumpAndSettle();
      expect(find.text('Indoor training'), findsNothing);
      expect(find.text('Real description'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      connection.dispose();
    },
  );

  testWidgets(
    'graphs served from the offline cache render with the last-updated chip',
    (tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      tester.view.physicalSize = const Size(420, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final connection = ValueNotifier<String?>('a');
      final repository = _CachedGraphsRepository();
      final controller = ServerActivityDetailController(
        activityId: 7,
        repository: repository,
        connection: connection,
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ServerActivityDetailScreen(
            activityId: 7,
            controller: controller,
            tileServerUrlProvider: () async =>
                'https://tiles.example/{z}/{x}/{y}.png',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final chips = find.byType(CacheLastUpdatedChip);
      expect(chips, findsNWidgets(2));
      await tester.scrollUntilVisible(chips.first, 200);
      await tester.pumpAndSettle();
      final chipText = tester
          .widget<Text>(
            find.descendant(of: chips.first, matching: find.byType(Text)),
          )
          .data;
      expect(chipText, startsWith('Last updated'));
      expect(find.byKey(const ValueKey('chart-heartRate')), findsOneWidget);
      expect(find.text('Could not load the graphs.'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      connection.dispose();
    },
  );
}

class _Repository implements ServerActivitiesRepository {
  @override
  Future<ServerActivity> fetchDetail(int activityId) async =>
      const ServerActivity(
        id: 7,
        name: 'Indoor training',
        activityType: 10,
        timerSeconds: 1800,
        averageHeartRate: 125,
        calories: 300,
        description: 'Real description',
      );
  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) async => [];
  @override
  Future<List<int>> fetchActivityTypes() => throw UnimplementedError();
  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) => throw UnimplementedError();
}

class _OutdoorRepository extends _Repository {
  int routeCalls = 0;
  int detailCalls = 0;
  @override
  Future<ServerActivity> fetchDetail(int activityId) async {
    detailCalls++;
    return ServerActivity(
      id: 7,
      name: 'River run',
      activityType: 1,
      startTime: DateTime.utc(2026, 10, 18, 8),
      city: 'Berlin',
      country: 'Germany',
      distanceMeters: 5000,
      timerSeconds: 1500,
      elapsedSeconds: 1700,
      averageSpeedMetersPerSecond: 10 / 3,
      elevationGainMeters: 23,
      averagePower: 200,
    );
  }

  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) async {
    routeCalls++;
    if (routeCalls == 1) throw Exception('offline');
    return const [
      ServerRoutePoint(latitude: 52, longitude: 13),
      ServerRoutePoint(latitude: 52.01, longitude: 13.01),
    ];
  }
}

class _PlaybackRepository extends _Repository
    implements ServerActivityGraphRepository {
  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) async =>
      List.generate(
        3,
        (i) => ServerRoutePoint(
          latitude: 52 + i / 100,
          longitude: 13 + i / 100,
          time: DateTime.utc(2026, 10, 18, 10, 0, i * 10),
        ),
      );
  @override
  Future<List<ServerActivityGraph>> fetchGraphs(int activityId) async => [
    ServerActivityGraph.fromJson({
      'stream_type': 1,
      'stream_waypoints': List.generate(
        3,
        (i) => {
          'time': DateTime.utc(2026, 10, 18, 10, 0, i * 10).toIso8601String(),
          'hr': 120 + i * 10,
        },
      ),
    }),
  ];
  @override
  Future<List<ServerActivityLap>> fetchLaps(int activityId) async => [];
}

class _CachedGraphsRepository extends _Repository
    implements ServerActivityGraphRepository, OfflineCacheProvenance {
  final _provenance = <Object, OfflineCacheServeInfo>{};

  @override
  OfflineCacheServeInfo? provenanceOf(Object result) => _provenance[result];

  @override
  Future<List<ServerActivityGraph>> fetchGraphs(int activityId) async {
    final graphs = [
      ServerActivityGraph.fromJson({
        'stream_type': 1,
        'stream_waypoints': [
          {'time': '2026-10-18T10:00:00Z', 'hr': 121},
        ],
      }),
    ];
    _provenance[graphs] = OfflineCacheServeInfo(
      fetchedAt: DateTime.utc(2026, 10, 25, 9),
    );
    return graphs;
  }

  @override
  Future<List<ServerActivityLap>> fetchLaps(int activityId) async {
    const laps = [
      ServerActivityLap(
        distanceMeters: 1000,
        seconds: 300,
        speed: 3,
        heartRate: 120,
        isRest: false,
      ),
    ];
    _provenance[laps] = OfflineCacheServeInfo(
      fetchedAt: DateTime.utc(2026, 10, 25, 9),
    );
    return laps;
  }
}
