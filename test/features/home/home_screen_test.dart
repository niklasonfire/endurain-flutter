import 'package:endurain/core/localization/app_locales.dart';
import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/features/home/controllers/home_controller.dart';
import 'package:endurain/features/home/screens/home_screen.dart';
import 'package:endurain/features/home/widgets/home_activity_card.dart';
import 'package:endurain/features/goals/repositories/goals_repository.dart';
import 'package:endurain/features/goals/models/goal_progress.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/statistics/repositories/statistics_repository.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';

import '../../helpers/device_locale.dart';
import '../../helpers/widget_test_app.dart';

import 'package:endurain/features/server_activities/screens/server_activity_detail_screen.dart';

class UnavailableActivities implements ServerActivitiesRepository {
  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) async => throw Exception('offline');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class UnavailableStatistics implements StatisticsRepository {
  @override
  Future<ActivityStatistics> fetch(StatisticsQuery query) =>
      Future.error(Exception('offline'));
}

class EmptyGoals implements GoalsRepository {
  @override
  Future<List<GoalProgress>> fetchResults() async => [];
}

class SampleStatistics implements StatisticsRepository {
  @override
  Future<ActivityStatistics> fetch(StatisticsQuery query) async =>
      const ActivityStatistics(
        totals: StatisticsMetrics(
          distanceMeters: 27400,
          durationSeconds: 13320,
          elevationMeters: 200,
          count: 5,
        ),
        sports: [
          StatisticsSport(
            id: 1,
            apiName: 'Run',
            metrics: StatisticsMetrics(
              distanceMeters: 27400,
              durationSeconds: 13320,
              elevationMeters: 200,
              count: 5,
            ),
          ),
        ],
        buckets: [
          StatisticsBucket(
            0,
            StatisticsMetrics(
              distanceMeters: 5000,
              durationSeconds: 3600,
              elevationMeters: 0,
              count: 2,
            ),
          ),
          StatisticsBucket(
            5,
            StatisticsMetrics(
              distanceMeters: 22400,
              durationSeconds: 9720,
              elevationMeters: 200,
              count: 3,
            ),
          ),
        ],
      );
}

class SampleActivities extends UnavailableActivities {
  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) async => ServerActivityPage(
    items: [
      const ServerActivity(
        id: 1,
        name: 'Morning run',
        activityType: 1,
        distanceMeters: 5800,
        timerSeconds: 2400,
      ),
    ],
    page: 1,
    pageSize: 3,
    total: 1,
  );
  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) async => [
    const ServerRoutePoint(latitude: 52.50, longitude: 13.40),
    const ServerRoutePoint(latitude: 52.51, longitude: 13.42),
    const ServerRoutePoint(
      latitude: 52.52,
      longitude: 13.41,
      startsSegment: true,
    ),
    const ServerRoutePoint(latitude: 52.53, longitude: 13.43),
  ];
}

class SampleGoals implements GoalsRepository {
  @override
  Future<List<GoalProgress>> fetchResults() async => List.generate(
    4,
    (i) => GoalProgress(
      id: i,
      interval: 'weekly',
      activityType: 'Run',
      goalType: 'distance',
      startDate: DateTime.utc(2026, 10, 12),
      endDate: DateTime.utc(2026, 10, 18),
      achieved: 18400,
      target: 25000,
      percentage: 73.6,
    ),
  );
}

class ApiSportGoals implements GoalsRepository {
  @override
  Future<List<GoalProgress>> fetchResults() async =>
      ['run', 'bike', 'swim', 'walk', 'strength', 'cardio']
          .asMap()
          .entries
          .map(
            (entry) => GoalProgress(
              id: entry.key,
              interval: 'weekly',
              activityType: entry.value,
              goalType: 'duration',
              startDate: DateTime.utc(2026, 10, 12),
              endDate: DateTime.utc(2026, 10, 18),
              achieved: 1800,
              target: 3600,
              percentage: 50,
            ),
          )
          .toList();
}

/// Goals repository that reports which results came from the offline read
/// cache, like CachedGoalsRepository.
class OfflineCachedGoals implements GoalsRepository, OfflineCacheProvenance {
  DateTime? fromCache;
  @override
  Future<List<GoalProgress>> fetchResults() async => List.generate(
    4,
    (i) => GoalProgress(
      id: i,
      interval: 'weekly',
      activityType: 'Run',
      goalType: 'distance',
      startDate: DateTime.utc(2026, 10, 12),
      endDate: DateTime.utc(2026, 10, 18),
      achieved: 18400,
      target: 25000,
      percentage: 73.6,
    ),
  );
  @override
  OfflineCacheServeInfo? provenanceOf(Object result) =>
      fromCache == null ? null : OfflineCacheServeInfo(fetchedAt: fromCache!);
}

void main() {
  setUp(() => useDeviceLocale(metricDeviceLocale));
  testWidgets(
    'record action stays visible with large text, scroll, loading and errors',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final connection = ValueNotifier<String?>('account');
      final controller = HomeController(
        statisticsRepository: UnavailableStatistics(),
        activitiesRepository: UnavailableActivities(),
        goalsRepository: EmptyGoals(),
        connection: connection,
      );
      var opened = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: HomeScreen(
            controller: controller,
            onRecordActivity: () => opened++,
            onOpenActivities: () {},
          ),
        ),
      );
      final button = find.text('Record Activity');
      expect(button.hitTestable(), findsOneWidget);
      final before = tester.getCenter(button);
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('home-scroll')),
        const Offset(0, -1800),
      );
      await tester.pumpAndSettle();
      expect(tester.getCenter(button), before);
      expect(button.hitTestable(), findsOneWidget);
      await tester.tap(button);
      expect(opened, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      connection.dispose();
    },
  );
  testWidgets(
    'shows real week values, goals, activities and active recording action',
    (tester) async {
      final connection = ValueNotifier<String?>('account');
      final controller = HomeController(
        statisticsRepository: SampleStatistics(),
        activitiesRepository: SampleActivities(),
        goalsRepository: SampleGoals(),
        connection: connection,
        now: () => DateTime.utc(2026, 10, 18),
      );
      var opened = false;
      await tester.pumpWidget(
        TestAppScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(
              controller: controller,
              onRecordActivity: () => opened = true,
              onOpenActivities: () {},
              hasActiveRecording: true,
              isRecordingPaused: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('3:42:00'), findsOneWidget);
      expect(find.text('5 activities'), findsOneWidget);
      expect(find.text('In motion on 2 days. Well done!'), findsOneWidget);
      expect(find.text('Recording paused'), findsOneWidget);
      await tester.tap(find.text('Return to recording'));
      expect(opened, isTrue);
      await tester.scrollUntilVisible(
        find.text('All goals'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('All goals'));
      await tester.pumpAndSettle();
      expect(find.text('18.40 km / 25.00 km'), findsWidgets);
      expect(find.text('6.60 km to your goal'), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Morning run'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Morning run'), findsOneWidget);
      expect(find.text('Run'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(HomeActivityCard),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
      );
      expect(find.text('Return to recording').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Morning run'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ServerActivityDetailScreen>(
              find.byType(ServerActivityDetailScreen),
            )
            .activityId,
        1,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      connection.dispose();
    },
  );
  testWidgets('all supported Endurain goal sports use German labels', (
    tester,
  ) async {
    final connection = ValueNotifier<String?>('account');
    final controller = HomeController(
      statisticsRepository: SampleStatistics(),
      activitiesRepository: SampleActivities(),
      goalsRepository: ApiSportGoals(),
      connection: connection,
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreen(
          controller: controller,
          onRecordActivity: () {},
          onOpenActivities: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Alle Ziele'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Alle Ziele'));
    await tester.pumpAndSettle();
    for (final label in [
      'Laufen',
      'Radfahren',
      'Schwimmen',
      'Gehen',
      'Krafttraining',
      'Cardiotraining',
    ]) {
      await tester.scrollUntilVisible(
        find.text('$label · Wöchentlich'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('$label · Wöchentlich'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    connection.dispose();
  });
  testWidgets('offline cached goals show the Last updated chip', (
    tester,
  ) async {
    final connection = ValueNotifier<String?>('account');
    final goals = OfflineCachedGoals();
    final controller = HomeController(
      statisticsRepository: SampleStatistics(),
      activitiesRepository: SampleActivities(),
      goalsRepository: goals,
      connection: connection,
      now: () => DateTime.utc(2026, 10, 18),
    );
    await tester.pumpWidget(
      TestAppScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(
            controller: controller,
            onRecordActivity: () {},
            onOpenActivities: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('All goals'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Last updated'), findsNothing);

    // Offline: the goals come from the offline read cache and the chip marks
    // them, in the home section and in the All goals screen.
    goals.fromCache = DateTime.utc(2026, 10, 17, 12);
    await controller.refresh();
    await tester.pumpAndSettle();
    expect(find.textContaining('Last updated'), findsOneWidget);
    await tester.tap(find.text('All goals'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Last updated'), findsOneWidget);

    // Back online: the next refresh comes from the server and hides the chip.
    goals.fromCache = null;
    await controller.refresh();
    await tester.pumpAndSettle();
    expect(find.textContaining('Last updated'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    connection.dispose();
  });
}
