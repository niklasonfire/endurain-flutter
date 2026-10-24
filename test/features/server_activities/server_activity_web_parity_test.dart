import 'dart:convert';

import 'package:endurain/core/localization/app_locales.dart';
import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/base_http_client.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/features/server_activities/controllers/server_activity_detail_controller.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:endurain/features/server_activities/repositories/api_server_activities_repository.dart';
import 'package:endurain/features/server_activities/screens/server_activity_detail_screen.dart';
import 'package:endurain/features/server_activities/widgets/server_activity_list_item.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthSessionStore sessions;
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    sessions = AuthSessionStore(storage: SecureStorageService());
    await sessions.saveSession(
      origin: 'https://example.test',
      accessToken: 'access',
      refreshToken: 'refresh',
      sessionId: 'session',
      accountId: 'account',
      expiresInSeconds: 3600,
    );
  });

  ApiServerActivitiesRepository repository(Map<String, Object?> fields) =>
      ApiServerActivitiesRepository(
        sessionStore: sessions,
        apiClient: ApiClient(
          sessionStore: sessions,
          baseClient: BaseHttpClient(
            httpClient: MockClient((request) async {
              if (request.url.path.endsWith('/streams') ||
                  request.url.path.endsWith('/laps')) {
                return http.Response(
                  jsonEncode({
                    'items': const <Object>[],
                    'total': 0,
                    'page': 1,
                    'num_records': 200,
                    'next': null,
                  }),
                  200,
                );
              }
              if (request.url.path.endsWith('/streams/7')) {
                return http.Response('null', 200);
              }
              return http.Response(
                jsonEncode({
                  'id': 7,
                  'name': 'Imported run',
                  'activity_type': 1,
                  'distance': 3056,
                  'total_elapsed_time': 1260.998,
                  'total_timer_time': 1260.998,
                  'pace': 0.412623,
                  'average_speed': 2.4722433164,
                  ...fields,
                }),
                200,
              );
            }),
          ),
        ),
      );

  test(
    'v0.20 start_time is a UTC instant and renders as an absolute time',
    () async {
      final activity = await repository({
        'start_time': '2026-10-18T15:15:35Z',
      }).fetchDetail(7);
      expect(activity.startTime, DateTime.utc(2026, 10, 18, 15, 15, 35));
      expect(activity.displayStartTime!.instantUtc, isNotNull);
      expect(
        activity.displayStartTime!.format(DateFormat('yyyy-MM-dd HH:mm')),
        isNotEmpty,
      );
    },
  );

  test(
    'hidden start time stays null without any fallback field',
    () async {
      final activity = await repository({
        'start_time': null,
      }).fetchDetail(7);
      expect(activity.startTime, isNull);
      expect(activity.displayStartTime, isNull);
    },
  );

  testWidgets(
    'API values render the same start time, pace and duration as web',
    (tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('de', 'DE');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      final repo = repository({
        'start_time': '2026-10-18T17:15:35Z',
      });
      final parsedActivity = await tester.runAsync(() => repo.fetchDetail(7));
      final connection = ValueNotifier<String?>('account');
      final controller = ServerActivityDetailController(
        activityId: 7,
        repository: _LoadedRepository(parsedActivity!),
        connection: connection,
      );
      Widget app(Widget child) => MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      );
      await tester.pumpWidget(
        app(
          ServerActivityDetailScreen(
            activityId: 7,
            controller: controller,
            tileServerUrlProvider: () async =>
                'https://tiles.example/{z}/{x}/{y}.png',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('6:53 min/km'), findsOneWidget);
      expect(find.text('21:00'), findsOneWidget);
      expect(find.text('6:44 min/km'), findsNothing);
      expect(find.text('21:01'), findsNothing);
      final activity = controller.activity!;
      await tester.pumpWidget(
        app(Scaffold(body: ServerActivityListItem(activity: activity))),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('6:53 min/km'), findsOneWidget);
      expect(find.textContaining('21:00'), findsOneWidget);
      expect(find.textContaining('18. Okt. 2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      connection.dispose();
    },
  );
}

// The API is exercised before entering widget fake time, so secure-storage
// platform futures do not keep the loading animation running indefinitely.
class _LoadedRepository extends Fake implements ServerActivitiesRepository {
  _LoadedRepository(this.activity);
  final ServerActivity activity;
  @override
  Future<ServerActivity> fetchDetail(int activityId) async => activity;
  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) async => const [];
}
