import 'package:endurain/core/localization/app_locales.dart';
import 'package:endurain/features/server_activities/controllers/server_activities_controller.dart';
import 'package:endurain/features/home/widgets/home_activity_card.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:endurain/features/server_activities/screens/server_activities_screen.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:endurain/features/server_activities/widgets/server_activity_list_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/device_locale.dart';

void main() {
  setUp(() => useDeviceLocale(metricDeviceLocale));
  Widget app(
    Widget child, {
    Locale locale = const Locale('en'),
    Brightness brightness = Brightness.light,
  }) => MaterialApp(
    locale: locale,
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(brightness: brightness),
    home: child,
  );

  testWidgets('swimming shows metres and pace per hundred metres', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const Scaffold(
          body: ServerActivityListItem(
            activity: ServerActivity(
              id: 8,
              name: 'Pool',
              activityType: 8,
              distanceMeters: 1500,
              averageSpeedMetersPerSecond: 1.25,
              paceSecondsPerMeter: 0.8,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('1,500 m'), findsOneWidget);
    expect(find.textContaining('1:20 min/100m'), findsOneWidget);
  });

  testWidgets('guest can connect account without loading server data', (
    tester,
  ) async {
    final connection = ValueNotifier<String?>(null);
    final repository = _Repository();
    final controller = ServerActivitiesController(
      repository: repository,
      connection: connection,
    );
    var signIn = false;
    await tester.pumpWidget(
      app(
        ServerActivitiesScreen(
          controller: controller,
          onSignIn: () => signIn = true,
        ),
        locale: const Locale('de'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Deine Aktivitäten an einem Ort'), findsOneWidget);
    await tester.tap(find.text('Account verbinden'));
    expect(signIn, isTrue);
    expect(repository.queries, isEmpty);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    connection.dispose();
  });

  testWidgets(
    'shows Home activity cards with route previews and opens selected activity in dark mode',
    (tester) async {
      final connection = ValueNotifier<String?>('account');
      final repository = _Repository();
      final controller = ServerActivitiesController(
        repository: repository,
        connection: connection,
      );
      ServerActivity? selected;
      await tester.pumpWidget(
        app(
          ServerActivitiesScreen(
            controller: controller,
            onOpenActivity: (activity) => selected = activity,
          ),
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Morning run'), findsOneWidget);
      expect(find.byType(HomeActivityCard), findsOneWidget);
      expect(repository.routeRequests, [1]);
      expect(
        find.descendant(
          of: find.byType(HomeActivityCard),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
      );
      expect(find.textContaining('Berlin'), findsOneWidget);
      expect(find.textContaining('5.00 km'), findsOneWidget);
      expect(find.textContaining('5:00 min/km'), findsOneWidget);
      await tester.tap(find.text('Morning run'));
      expect(selected?.id, 1);
      await tester.enterText(find.byType(TextField), 'forest');
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(repository.queries.last.search, 'forest');
      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();
      expect(repository.queries.last.search, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      connection.dispose();
    },
  );

  testWidgets('account switch cancels a pending search and clears its field', (
    tester,
  ) async {
    final connection = ValueNotifier<String?>('a');
    final repository = _Repository();
    final controller = ServerActivitiesController(
      repository: repository,
      connection: connection,
    );
    await tester.pumpWidget(
      app(ServerActivitiesScreen(controller: controller)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'private query');
    connection.value = 'b';
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
    expect(repository.queries.last.search, isEmpty);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    connection.dispose();
  });
  testWidgets(
    'paged cards request only viewport routes and preserve empty search state',
    (tester) async {
      final connection = ValueNotifier<String?>('account');
      final repository = _PagedRepository();
      final controller = ServerActivitiesController(
        repository: repository,
        connection: connection,
      );
      await tester.pumpWidget(
        app(ServerActivitiesScreen(controller: controller)),
      );
      await tester.pumpAndSettle();
      expect(repository.routeRequests, isNotEmpty);
      expect(repository.routeRequests.length, lessThan(10));
      expect(repository.pages, [1]);
      await tester.scrollUntilVisible(
        find.text('Activity 21'),
        350,
        maxScrolls: 30,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(repository.pages, [1, 2]);
      expect(find.text('Activity 21'), findsOneWidget);
      expect(repository.routeRequests.length, lessThan(40));
      await tester.enterText(find.byType(TextField), 'no matches');
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.text('No activities match your filters.'), findsOneWidget);
      expect(find.byType(HomeActivityCard), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      connection.dispose();
    },
  );
  testWidgets(
    'pull refresh retries failed previews and reuses successful routes including GPS-less activities',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final connection = ValueNotifier<String?>('account');
      final repository = _RetryRouteRepository();
      final controller = ServerActivitiesController(
        repository: repository,
        connection: connection,
      );
      await tester.pumpWidget(
        app(ServerActivitiesScreen(controller: controller)),
      );
      await tester.pumpAndSettle();
      final firstCard = find.byWidgetPredicate(
        (widget) => widget is HomeActivityCard && widget.activity.id == 1,
      );
      expect(
        find.descendant(
          of: firstCard,
          matching: find.byIcon(Icons.directions_run),
        ),
        findsOneWidget,
      );
      expect(repository.attempts, {1: 1, 2: 1, 3: 1});
      await tester.drag(find.byType(ListView), const Offset(0, 350));
      await tester.pumpAndSettle();
      expect(repository.attempts, {1: 2, 2: 1, 3: 1});
      expect(
        find.descendant(
          of: firstCard,
          matching: find.byIcon(Icons.directions_run),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      connection.dispose();
    },
  );
}

class _Repository implements ServerActivitiesRepository {
  final queries = <ServerActivityQuery>[];
  final routeRequests = <int>[];
  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) async {
    queries.add(query);
    return ServerActivityPage(
      items: [
        ServerActivity(
          id: 1,
          name: 'Morning run',
          activityType: 1,
          startTime: DateTime.utc(2026, 10, 17),
          distanceMeters: 5000,
          timerSeconds: 1500,
          averageSpeedMetersPerSecond: 10 / 3,
          city: 'Berlin',
        ),
      ],
      page: 1,
      pageSize: 20,
      total: 1,
    );
  }

  @override
  Future<List<int>> fetchActivityTypes() async => [1, 4];
  @override
  Future<ServerActivity> fetchDetail(int activityId) =>
      throw UnimplementedError();
  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) async {
    routeRequests.add(activityId);
    return const [
      ServerRoutePoint(latitude: 52.5, longitude: 13.4),
      ServerRoutePoint(latitude: 52.51, longitude: 13.41),
    ];
  }
}

class _PagedRepository extends _Repository {
  final pages = <int>[];
  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) async {
    pages.add(page);
    return ServerActivityPage(
      items: query.search.isNotEmpty
          ? []
          : List.generate(
              20,
              (i) => ServerActivity(
                id: (page - 1) * 20 + i + 1,
                name: 'Activity ${(page - 1) * 20 + i + 1}',
                activityType: 1,
              ),
            ),
      page: page,
      pageSize: 20,
      total: query.search.isNotEmpty ? 0 : 40,
    );
  }
}

class _RetryRouteRepository extends _Repository {
  final attempts = <int, int>{};
  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) async => ServerActivityPage(
    items: const [
      ServerActivity(id: 1, name: 'Retry run', activityType: 1),
      ServerActivity(id: 2, name: 'Indoor run', activityType: 1),
      ServerActivity(id: 3, name: 'Outdoor run', activityType: 1),
    ],
    page: 1,
    pageSize: 20,
    total: 3,
  );
  @override
  Future<List<ServerRoutePoint>> fetchRoute(int id) async {
    attempts[id] = (attempts[id] ?? 0) + 1;
    if (id == 1 && attempts[id] == 1) throw Exception('temporarily offline');
    return id == 2
        ? const []
        : const [
            ServerRoutePoint(latitude: 52, longitude: 13),
            ServerRoutePoint(latitude: 52.01, longitude: 13.02),
          ];
  }
}
