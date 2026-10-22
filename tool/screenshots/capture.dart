// Render the fork's production screens with licensed, recorded GPX fixtures.
// Run with: flutter test tool/screenshots/capture.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:endurain/core/theme/app_theme.dart';
import 'package:endurain/core/localization/app_locales.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:endurain/features/goals/models/goal_progress.dart';
import 'package:endurain/features/goals/repositories/goals_repository.dart';
import 'package:endurain/features/home/controllers/home_controller.dart';
import 'package:endurain/features/home/screens/home_screen.dart';
import 'package:endurain/features/server_activities/controllers/server_activities_controller.dart';
import 'package:endurain/features/server_activities/controllers/server_activity_detail_controller.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';

import 'sample_activity.dart';

import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:endurain/features/server_activities/repositories/server_activity_graph_repository.dart';
import 'package:endurain/features/server_activities/screens/server_activities_screen.dart';
import 'package:endurain/features/server_activities/screens/server_activity_detail_screen.dart';
import 'package:endurain/features/statistics/controllers/statistics_controller.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/statistics_repository.dart';
import 'package:endurain/features/statistics/screens/statistics_screen.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;

final _samples = readSampleActivities();
final _date = _samples.first.activity.startTime!;
final _boundary = GlobalKey();
final _tileRequests = <String>{};

List<SampleActivity> _inWeek(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  final start = day.subtract(Duration(days: day.weekday - 1));
  final end = start.add(const Duration(days: 7));
  return _samples.where((sample) {
    final time = sample.activity.startTime!;
    return !time.isBefore(start) && time.isBefore(end);
  }).toList();
}

class _Activities
    implements ServerActivitiesRepository, ServerActivityGraphRepository {
  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) async => ServerActivityPage(
    items: _samples.map((sample) => sample.activity).toList(),
    page: 1,
    pageSize: pageSize,
    total: _samples.length,
  );
  @override
  Future<List<int>> fetchActivityTypes() async => [1];
  @override
  Future<ServerActivity> fetchDetail(int activityId) async => _samples
      .firstWhere((sample) => sample.activity.id == activityId)
      .activity;
  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) async =>
      _samples.firstWhere((sample) => sample.activity.id == activityId).route;
  @override
  Future<List<ServerActivityGraph>> fetchGraphs(int activityId) async =>
      _samples.firstWhere((sample) => sample.activity.id == activityId).graphs;
  @override
  Future<List<ServerActivityLap>> fetchLaps(int activityId) async => [];
}

class _Statistics implements StatisticsRepository {
  @override
  Future<ActivityStatistics> fetch(StatisticsQuery query) async {
    final samples = _inWeek(query.date);
    final totals = sumMetrics(samples);
    return ActivityStatistics(
      totals: totals,
      sports: [StatisticsSport(id: 1, apiName: 'Run', metrics: totals)],
      buckets: [
        for (var day = 0; day < 7; day++)
          StatisticsBucket(
            day,
            sumMetrics(
              samples.where(
                (sample) => sample.activity.startTime!.weekday - 1 == day,
              ),
            ),
          ),
      ],
    );
  }
}

class _Goals implements GoalsRepository {
  @override
  Future<List<GoalProgress>> fetchResults() async {
    final achieved = sumMetrics(_inWeek(_date)).distanceMeters;
    // A demonstration goal; recorded activity totals come exclusively from GPX.
    final target = ((achieved / 10000).floor() + 1) * 10000.0;
    final day = DateTime.utc(_date.year, _date.month, _date.day);
    final start = day.subtract(Duration(days: day.weekday - 1));
    return [
      GoalProgress(
        id: 1,
        interval: 'weekly',
        activityType: 'run',
        goalType: 'distance',
        startDate: start,
        endDate: start.add(const Duration(days: 6)),
        achieved: achieved,
        target: target,
        percentage: achieved / target * 100,
      ),
    ];
  }
}

// Serve cached OSM tiles without networking in Flutter's widget-test binding.
class _Tiles extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _TileClient();
}

class _TileClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _TileRequest(url);
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _TileRequest(url);
  @override
  void close({bool force = false}) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TileRequest implements HttpClientRequest {
  _TileRequest(this.url);
  final Uri url;
  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}
  @override
  bool followRedirects = true;
  @override
  int maxRedirects = 5;
  @override
  int contentLength = 0;
  @override
  bool persistentConnection = true;
  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await stream.drain<void>();
  }

  @override
  final HttpHeaders headers = _Headers();
  @override
  Future<HttpClientResponse> close() async {
    _tileRequests.add(url.toString());
    final tile = File('build/readme-tiles${url.path}');
    return _TileResponse(tile.existsSync() ? tile.readAsBytesSync() : null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Headers implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void forEach(void Function(String, List<String>) action) {}

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  List<String>? operator [](String name) => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TileResponse extends Stream<List<int>> implements HttpClientResponse {
  _TileResponse(this.bytes);
  final Uint8List? bytes;
  @override
  bool get isRedirect => false;
  @override
  List<RedirectInfo> get redirects => [];
  @override
  bool get persistentConnection => true;
  @override
  String get reasonPhrase => bytes == null ? 'Not Found' : 'OK';
  @override
  int get statusCode => bytes == null ? 404 : 200;
  @override
  int get contentLength => bytes?.length ?? 0;
  @override
  final HttpHeaders headers = _Headers();
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.fromIterable([?bytes]).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _tabs(Widget screen, int selected) => AdaptiveBottomNavigation(
  selectedIndex: selected,
  tabs: [
    for (final (index, label, icon) in [
      (0, 'Home', Icons.home_rounded),
      (1, 'Activities', Icons.directions_run),
      (2, 'Statistics', Icons.bar_chart),
      (3, 'Settings', Icons.settings),
    ])
      AdaptiveTab(
        routeName: '/$index',
        label: label,
        materialIcon: icon,
        cupertinoIcon: CupertinoIcons.circle,
        builder: (_) => index == selected ? screen : const SizedBox.shrink(),
      ),
  ],
);

Future<void> _mount(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundary,
      child: MaterialApp(
        title: 'Endurain',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme.copyWith(
          textTheme: AppTheme.lightTheme.textTheme.apply(
            fontFamilyFallback: const ['ScreenshotSymbols'],
          ),
        ),
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
  // Tile-cache workers and image decoding use the real event loop. Alternate
  // real work with frames until the asynchronous map pipeline has rendered.
  for (var frame = 0; frame < 6; frame++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
  }
}

Future<void> _save(WidgetTester tester, String name) async {
  expect(tester.takeException(), isNull);
  final boundary =
      _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('docs/screenshots/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture README screens', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localeTestValue = const Locale('en', 'AU');
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    final mapCache = BuiltInMapCachingProvider.getOrCreateInstance(
      cacheDirectory: Directory('build/readme-map-cache').absolute.path,
    );
    addTearDown(() {
      unawaited(mapCache.destroy());
    });
    final previousOverrides = HttpOverrides.current;
    HttpOverrides.global = _Tiles();
    addTearDown(() => HttpOverrides.global = previousOverrides);

    final sdk = Platform.environment['FLUTTER_HOME']!;
    final font = FontLoader('Roboto');
    for (final weight in ['Regular', 'Medium']) {
      final bytes = File(
        '$sdk/engine/src/flutter/txt/third_party/fonts/Roboto-$weight.ttf',
      ).readAsBytesSync();
      font.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
            ).readAsBytesSync(),
          ),
        ),
      );
    await icons.load();
    final symbolPath =
        Platform.environment['ENDURAIN_SCREENSHOT_SYMBOL_FONT'] ??
        '/usr/share/fonts/truetype/noto/NotoSansSymbols-Regular.ttf';
    final symbols = FontLoader('ScreenshotSymbols')
      ..addFont(
        Future.value(ByteData.sublistView(File(symbolPath).readAsBytesSync())),
      );
    await symbols.load();
    final activities = _Activities();
    final connection = ValueNotifier<String?>('demo');
    final home = HomeController(
      statisticsRepository: _Statistics(),
      activitiesRepository: activities,
      goalsRepository: _Goals(),
      connection: connection,
      now: () => _date,
    );
    final list = ServerActivitiesController(
      repository: activities,
      connection: connection,
    );
    final detail = ServerActivityDetailController(
      activityId: _samples.first.activity.id,
      repository: activities,
      connection: connection,
    );
    final statistics = StatisticsController(
      repository: _Statistics(),
      connection: connection,
    )..query = StatisticsQuery(date: _date);
    addTearDown(() {
      home.dispose();
      list.dispose();
      detail.dispose();
      statistics.dispose();
      connection.dispose();
    });

    await _mount(
      tester,
      _tabs(
        HomeScreen(
          controller: home,
          onRecordActivity: () {},
          onOpenActivities: () {},
        ),
        0,
      ),
    );
    await _save(tester, 'home');
    await _mount(tester, _tabs(ServerActivitiesScreen(controller: list), 1));
    await _save(tester, 'activities');
    await _mount(
      tester,
      ServerActivityDetailScreen(
        activityId: _samples.first.activity.id,
        controller: detail,
        tileServerUrlProvider: () async =>
            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      ),
    );
    await _save(tester, 'activity-details');
    final scroll = tester
        .state<ScrollableState>(
          find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
        )
        .position;
    scroll.jumpTo(scroll.maxScrollExtent);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('chart-pace')));
    await tester.pumpAndSettle();
    await _save(tester, 'activity-charts');
    await _mount(tester, _tabs(StatisticsScreen(controller: statistics), 2));
    await _save(tester, 'statistics');
    await tester.pumpWidget(const SizedBox.shrink());
    File('build/readme-tile-requests.txt')
        .writeAsStringSync(_tileRequests.join('\n'));
  });
}
