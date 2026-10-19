import 'package:endurain/features/achievements/widgets/achievement_record_card.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:endurain/core/services/base_http_client.dart';
import 'package:endurain/features/achievements/models/achievement_models.dart';
import 'package:endurain/features/achievements/repositories/achievements_repository.dart';
import 'package:endurain/features/achievements/repositories/achievement_store.dart';
import 'package:endurain/core/localization/app_locales.dart';
import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/features/achievements/controllers/achievements_controller.dart';
import 'package:endurain/features/achievements/repositories/local_achievements_repository.dart';
import 'package:endurain/features/achievements/services/achievement_scan_service.dart';
import 'package:endurain/features/achievements/services/achievement_server_source.dart';
import 'package:endurain/features/achievements/screens/personal_bests_screen.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'partial activity failures explain retained records and offer retry',
    (tester) async {
      final fixture = await _Fixture.create(
        tester,
        const AchievementScanState(
          status: AchievementScanStatus.partial,
          processedCount: 1,
          totalCount: 1,
          firstDayOfWeek: 1,
          failures: {7: 'activityFetchFailed'},
        ),
      );
      await tester.pumpWidget(
        _app(PersonalBestsScreen(controller: fixture.controller)),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Saved results remain available'),
        200,
      );
      await tester.scrollUntilVisible(find.text('Try again'), 100);
      expect(find.text('Try again'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Fastest 1 km'), 200);
      expect(find.text('4:32'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await fixture.close();
    },
  );

  testWidgets('reopening derives records from the shared offline cache', (
    tester,
  ) async {
    final fixture = await _Fixture.create(
      tester,
      const AchievementScanState(
        status: AchievementScanStatus.complete,
        processedCount: 1,
        totalCount: 1,
        firstDayOfWeek: 1,
      ),
    );
    final reopened = AchievementsController(scanService: fixture.service);
    await tester.pumpWidget(_app(PersonalBestsScreen(controller: reopened)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Fastest 1 km'), 250);
    expect(find.text('4:32'), findsOneWidget);
    expect(find.text('History analysed'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    reopened.dispose();
    await fixture.close();
  });

  testWidgets(
    'partial cache displays estimated result and keeps it after refresh fails',
    (tester) async {
      final fixture = await _Fixture.create(
        tester,
        const AchievementScanState(
          status: AchievementScanStatus.partial,
          processedCount: 1,
          totalCount: 2,
          usableTrackCount: 1,
          firstDayOfWeek: 1,
        ),
      );
      await tester.pumpWidget(
        _app(PersonalBestsScreen(controller: fixture.controller)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Best found so far'), findsOneWidget);
      expect(find.text('1 of 2 activities analysed'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Fastest 1 km'), 250);
      expect(find.text('4:32'), findsOneWidget);
      expect(find.text('GPS estimate'), findsOneWidget);
      await tester.runAsync(fixture.controller.refresh);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Analysis could not finish.'),
        -250,
      );
      expect(
        find.textContaining('Saved results remain available'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(find.text('Fastest 1 km'), 250);
      expect(find.text('4:32'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await fixture.close();
    },
  );

  testWidgets(
    'sport/year filters survive narrow German dark mode and clear on account change',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = await _Fixture.create(
        tester,
        const AchievementScanState(
          status: AchievementScanStatus.complete,
          processedCount: 1,
          totalCount: 1,
          firstDayOfWeek: 1,
        ),
      );
      await tester.pumpWidget(
        _app(
          PersonalBestsScreen(controller: fixture.controller),
          locale: const Locale('de'),
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<int>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Laufen').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<int>).last);
      await tester.pumpAndSettle();
      await tester.runAsync(() => tester.tap(find.text('2026').last));
      await tester.runAsync(() => fixture.controller.setYear(2026));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Schnellste 1 km'), 200);
      expect(find.text('4:32'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        await fixture.sessions.saveSession(
          origin: 'https://other.test',
          accessToken: 'b',
          refreshToken: 'r',
          sessionId: 's',
          accountId: '43',
          expiresInSeconds: 3600,
        );
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pumpAndSettle();
      expect(find.text('4:32'), findsNothing);
      expect(find.text('Gesamter Zeitraum'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await fixture.close();
    },
  );

  testWidgets(
    'complete empty inventory differs from history with no eligible record',
    (tester) async {
      final fixture = await _Fixture.create(
        tester,
        const AchievementScanState(
          status: AchievementScanStatus.complete,
          processedCount: 0,
          totalCount: 0,
        ),
        records: false,
      );
      await tester.pumpWidget(
        _app(PersonalBestsScreen(controller: fixture.controller)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Your server history has no activities.'),
        findsOneWidget,
      );
      expect(find.text('History analysed'), findsOneWidget);
      expect(find.text('No records for these filters.'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await fixture.close();
    },
  );

  testWidgets(
    'partial week shows clipped range and lists every contributing activity',
    (tester) async {
      final start = DateTime.utc(2026, 1, 1);
      final record = AchievementRecord(
        winner: AchievementCandidate(
          activityId: 7,
          sportType: 1,
          metric: AchievementMetric.weeklyDistance,
          value: 12000,
          startedAt: start,
        ),
        sourceActivityIds: const [7, 9],
        year: 2026,
        periodStart: start,
        periodEnd: DateTime.utc(2026, 1, 5),
      );
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: SingleChildScrollView(
              child: AchievementRecordCard(record: record),
            ),
          ),
        ),
      );
      expect(find.text('Jan 1, 2026 – Jan 4, 2026 (UTC)'), findsOneWidget);
      expect(find.text('Partial week'), findsOneWidget);
      expect(find.text('Activity 7'), findsNothing);
      await tester.tap(find.text('Contributing activities'));
      await tester.pumpAndSettle();
      expect(find.text('Activity 7'), findsOneWidget);
      expect(find.text('Activity 9'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    },
  );

  testWidgets('guest sees connection guidance and no analysis controls', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final sessions = AuthSessionStore(storage: _MemorySecureStorage());
    final service = AchievementScanService(
      repository: LocalAchievementsRepository(),
      source: ApiAchievementServerSource(
        apiClient: ApiClient(sessionStore: sessions),
        sessionStore: sessions,
      ),
      sessionStore: sessions,
    );
    final controller = AchievementsController(scanService: service);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PersonalBestsScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Connect an Endurain account to analyse your activity history.',
      ),
      findsOneWidget,
    );
    expect(find.text('Analyse history'), findsNothing);
    expect(find.text('Calculated on this device'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    service.dispose();
  });
}

Widget _app(
  Widget home, {
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: ThemeData(brightness: brightness),
  home: home,
);

class _Fixture {
  _Fixture(this.sessions, this.repository, this.service, this.controller);
  final AuthSessionStore sessions;
  final LocalAchievementsRepository repository;
  final AchievementScanService service;
  final AchievementsController controller;
  static Future<_Fixture> create(
    WidgetTester tester,
    AchievementScanState state, {
    bool records = true,
  }) async {
    return (await tester.runAsync(() async {
      FlutterSecureStorage.setMockInitialValues({});
      final sessions = AuthSessionStore(storage: _MemorySecureStorage());
      await sessions.saveSession(
        origin: 'https://example.test',
        accessToken: 'a',
        refreshToken: 'r',
        sessionId: 's',
        accountId: '42',
        expiresInSeconds: 3600,
      );
      final repository = LocalAchievementsRepository(store: _MemoryStore());
      final scope = (await sessions.readSession())!.profileId;
      if (records) {
        final date = DateTime.utc(2026, 10, 1);
        await repository.replaceAnalysis(
          scope,
          AchievementAnalysis(
            activity: AchievementActivity(
              id: 7,
              sportType: 1,
              fingerprint: 'run',
              startedAt: date,
              distanceMeters: 5000,
            ),
            candidates: [
              AchievementCandidate(
                activityId: 7,
                sportType: 1,
                metric: AchievementMetric.fastestDistance,
                value: 272,
                startedAt: date,
                targetDistanceMeters: 1000,
                effortStart: date,
                effortEnd: date.add(const Duration(seconds: 272)),
                distanceSource: AchievementDistanceSource.gps,
              ),
            ],
            calculationVersion: 1,
          ),
        );
      }
      await repository.saveScanState(scope, state);
      final source = ApiAchievementServerSource(
        apiClient: ApiClient(
          sessionStore: sessions,
          baseClient: BaseHttpClient(
            httpClient: MockClient(
              (_) async => http.Response(jsonEncode({'error': 'offline'}), 200),
            ),
          ),
        ),
        sessionStore: sessions,
      );
      final service = AchievementScanService(
        repository: repository,
        source: source,
        sessionStore: sessions,
      );
      final controller = AchievementsController(scanService: service);
      await controller.initialize();
      return _Fixture(sessions, repository, service, controller);
    }))!;
  }

  Future<void> close() async {
    controller.dispose();
    service.dispose();
    await repository.close();
  }
}

// Persistence is a system boundary; the repository, calculator, controller and
// scan workflow remain real throughout these screen tests.
class _MemoryStore implements AchievementStore {
  final _analyses = <String, Map<int, AchievementAnalysis>>{};
  final _states = <String, AchievementScanState>{};
  @override
  Future<List<AchievementAnalysis>> loadAnalyses(String scope) async =>
      _analyses[scope]?.values.toList() ?? [];
  @override
  Future<AchievementScanState?> loadScanState(String scope) async =>
      _states[scope];
  @override
  Future<void> replaceAnalysis(
    String scope,
    AchievementAnalysis analysis, {
    AchievementScanState? checkpoint,
  }) async {
    (_analyses[scope] ??= {})[analysis.activity.id] = analysis;
    if (checkpoint != null) _states[scope] = checkpoint;
  }

  @override
  Future<void> saveScanState(String scope, AchievementScanState state) async {
    _states[scope] = state;
  }

  @override
  Future<void> completeInventory(
    String scope, {
    required Set<int> confirmedDeletedIds,
    required AchievementScanState state,
  }) async {
    _analyses[scope]?.removeWhere((id, _) => confirmedDeletedIds.contains(id));
    _states[scope] = state;
  }

  @override
  Future<void> clear(String scope) async {
    _analyses.remove(scope);
    _states.remove(scope);
  }

  @override
  Future<void> close() async {}
}

class _MemorySecureStorage extends SecureStorageService {
  final _values = <String, String>{};
  @override
  Future<String?> read({required String key}) async => _values[key];
  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }
}
