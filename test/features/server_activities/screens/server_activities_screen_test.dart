import 'package:endurain/core/localization/app_locales.dart';
import 'package:endurain/features/server_activities/controllers/server_activities_controller.dart';
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

  testWidgets('shows web-style rows and opens selected activity in dark mode', (
    tester,
  ) async {
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
  });

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
}

class _Repository implements ServerActivitiesRepository {
  final queries = <ServerActivityQuery>[];
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
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) =>
      throw UnimplementedError();
}
