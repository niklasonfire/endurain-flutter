import 'dart:convert';

import 'package:endurain/core/localization/app_locales.dart';
import 'package:endurain/core/models/measurement_system.dart';
import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/base_http_client.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/features/activity/services/activity_stats_formatter.dart';
import 'package:endurain/features/server_activities/controllers/server_activity_detail_controller.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/api_server_activities_repository.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:endurain/features/server_activities/screens/server_activity_detail_screen.dart';
import 'package:endurain/features/server_activities/services/server_activity_formatter.dart';
import 'package:endurain/features/server_activities/widgets/server_activity_list_item.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

// The attached run's unweighted GPS speed implied 6:44, although its aggregate
// pace is 6:53. Keep both values to catch accidental use of average speed.
const _run = ServerActivity(
  id: 7,
  name: 'Workout',
  activityType: 1,
  distanceMeters: 3056,
  elapsedSeconds: 1260.998,
  timerSeconds: 1200.999,
  paceSecondsPerMeter: 1261 / 3056,
  averageSpeedMetersPerSecond: 1000 / 404,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final l10n = lookupAppLocalizations(const Locale('en'));
  ServerActivityFormatter formatter({bool imperial = false}) =>
      ServerActivityFormatter(
        stats: ActivityStatsFormatter.of(
          l10n,
          system: imperial
              ? MeasurementSystem.imperial
              : MeasurementSystem.metric,
        ),
        l10n: l10n,
        locale: 'en',
      );

  test('server pace overrides average GPS speed and duration fallback', () {
    expect(formatter().activityTempo(_run), '6:53 min/km');
    expect(
      formatter().activityTempo(
        const ServerActivity(
          id: 1,
          name: '',
          activityType: 1,
          paceSecondsPerMeter: .3,
          elapsedSeconds: 1200,
          distanceMeters: 2000,
          averageSpeedMetersPerSecond: 1,
        ),
      ),
      '5:00 min/km',
    );
    expect(formatter(imperial: true).activityTempo(_run), '11:04 min/mi');
  });

  test(
    'missing pace uses elapsed distance ratio, then timer; never mean speed',
    () {
      expect(
        formatter().activityTempo(
          const ServerActivity(
            id: 1,
            name: '',
            activityType: 1,
            elapsedSeconds: 1260.998,
            timerSeconds: 1200,
            distanceMeters: 3056,
            averageSpeedMetersPerSecond: 1000 / 404,
          ),
        ),
        '6:53 min/km',
      );
      expect(
        formatter().activityTempo(
          const ServerActivity(
            id: 1,
            name: '',
            activityType: 1,
            timerSeconds: 1500,
            distanceMeters: 5000,
          ),
        ),
        '5:00 min/km',
      );
      for (final distance in [null, 0.0, -1.0, double.nan]) {
        expect(
          formatter().activityTempo(
            ServerActivity(
              id: 1,
              name: '',
              activityType: 1,
              timerSeconds: 1500,
              distanceMeters: distance,
              averageSpeedMetersPerSecond: 3,
            ),
          ),
          isNull,
        );
      }
    },
  );

  test('overflowing pace conversion remains unavailable', () {
    expect(
      formatter().activityTempo(
        const ServerActivity(
          id: 1,
          name: '',
          activityType: 1,
          paceSecondsPerMeter: 1e308,
        ),
      ),
      isNull,
    );
    expect(
      formatter().activityTempo(
        const ServerActivity(
          id: 1,
          name: '',
          activityType: 1,
          elapsedSeconds: 1e308,
          distanceMeters: 1e-308,
        ),
      ),
      isNull,
    );
  });

  test('sport pace units and speed sports retain their units', () {
    ServerActivity activity(int type) => ServerActivity(
      id: 1,
      name: '',
      activityType: type,
      paceSecondsPerMeter: 1.2,
      averageSpeedMetersPerSecond: 5,
    );
    for (final type in [8, 9]) {
      expect(formatter().activityTempo(activity(type)), '2:00 min/100m');
      expect(
        formatter(imperial: true).activityTempo(activity(type)),
        '1:50 min/100yd',
      );
    }
    for (final type in [13, 32, 42]) {
      expect(formatter().activityTempo(activity(type)), '10:00 min/500m');
      expect(
        formatter(imperial: true).activityTempo(activity(type)),
        '10:00 min/500m',
      );
    }
    expect(formatter().activityTempo(activity(4)), '18.0 km/h');
    expect(formatter(imperial: true).activityTempo(activity(4)), '11.2 mph');
    expect(formatter().activityTempo(activity(30)), '9.72 kn');
  });

  test('API retains server pace independently of average speed', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final sessions = AuthSessionStore(storage: SecureStorageService());
    await sessions.saveSession(
      origin: 'https://example.test',
      accessToken: 'access',
      refreshToken: 'refresh',
      sessionId: 's1',
      accountId: 'account',
      expiresInSeconds: 3600,
    );
    final repo = ApiServerActivitiesRepository(
      apiClient: ApiClient(
        sessionStore: sessions,
        baseClient: BaseHttpClient(
          httpClient: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'id': 7,
                'activity_type': 1,
                'name': 'Workout',
                'distance': 3056,
                'pace': 1261 / 3056,
                'total_elapsed_time': 1260.998,
                'average_speed': 1000 / 404,
              }),
              200,
            ),
          ),
        ),
      ),
      sessionStore: sessions,
    );
    final activity = await repo.fetchDetail(7);
    expect(activity.paceSecondsPerMeter, closeTo(1261 / 3056, .0000001));
    expect(formatter().activityTempo(activity), '6:53 min/km');
  });

  testWidgets('list uses timer, floors fractions, and displays server pace', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('de', 'DE');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    await tester.pumpWidget(_app(const ServerActivityListItem(activity: _run)));
    expect(find.textContaining('20:00 · 6:53 min/km'), findsOneWidget);
    expect(find.textContaining('20:01'), findsNothing);
    expect(find.textContaining('6:44'), findsNothing);
  });

  testWidgets(
    'detail uses elapsed, floors fractions, and displays server pace',
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
        _app(ServerActivityDetailScreen(activityId: 7, controller: controller)),
      );
      await tester.pumpAndSettle();
      expect(find.text('21:00'), findsOneWidget);
      expect(find.text('21:01'), findsNothing);
      expect(find.text('6:53 min/km'), findsOneWidget);
      expect(find.text('Elapsed time'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      connection.dispose();
    },
  );
}

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

class _Repository implements ServerActivitiesRepository {
  @override
  Future<ServerActivity> fetchDetail(int activityId) async => _run;
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
