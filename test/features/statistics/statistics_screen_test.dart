import 'package:endurain/core/localization/app_locales.dart';
import 'package:endurain/features/statistics/controllers/statistics_controller.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/statistics_repository.dart';
import 'package:endurain/features/statistics/screens/statistics_screen.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/device_locale.dart';

class Repository implements StatisticsRepository {
  final queries = <StatisticsQuery>[];
  @override
  Future<ActivityStatistics> fetch(StatisticsQuery query) async {
    queries.add(query);
    const run = StatisticsMetrics(
      distanceMeters: 10000,
      durationSeconds: 3600,
      elevationMeters: 150,
      count: 2,
    );
    const gym = StatisticsMetrics(
      distanceMeters: 2000,
      durationSeconds: 1800,
      elevationMeters: 0,
      count: 1,
    );
    return ActivityStatistics(
      totals: const StatisticsMetrics(
        distanceMeters: 12000,
        durationSeconds: 5400,
        elevationMeters: 150,
        count: 3,
      ),
      buckets: [
        StatisticsBucket(query.period == StatisticsPeriod.week ? 6 : 1, run),
      ],
      sports: const [
        StatisticsSport(id: 1, apiName: 'Run', metrics: run),
        StatisticsSport(id: 19, apiName: 'Strength training', metrics: gym),
      ],
    );
  }
}

Widget app(
  Widget child, {
  Locale locale = const Locale('de'),
  Brightness brightness = Brightness.light,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: ThemeData(brightness: brightness),
  home: child,
);
void main() {
  setUp(() => useDeviceLocale(metricDeviceLocale));
  testWidgets('guest has a connect action without fetching statistics', (
    tester,
  ) async {
    final repository = Repository();
    final connection = ValueNotifier<String?>(null);
    final controller = StatisticsController(
      repository: repository,
      connection: connection,
    );
    var connected = false;
    await tester.pumpWidget(
      app(
        StatisticsScreen(
          controller: controller,
          onSignIn: () => connected = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Account verbinden'));
    expect(connected, isTrue);
    expect(repository.queries, isEmpty);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    connection.dispose();
  });
  testWidgets(
    'shows full distance excluding gym in German dark mode and changes period',
    (tester) async {
      final repository = Repository();
      final connection = ValueNotifier<String?>('account');
      final controller = StatisticsController(
        repository: repository,
        connection: connection,
      );
      await tester.pumpWidget(
        app(
          StatisticsScreen(controller: controller),
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Gesamtdistanz'), findsOneWidget);
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('Gesamtdistanz'),
            matching: find.byType(Card),
          ),
          matching: find.text('10,00 km'),
        ),
        findsOneWidget,
      );
      expect(find.text('1:30:00'), findsOneWidget);
      await tester.tap(find.text('Monat'));
      await tester.pumpAndSettle();
      expect(repository.queries.last.period, StatisticsPeriod.month);
      expect(find.textContaining('Nur Wochen mit Aktivitäten'), findsOneWidget);
      connection.value = null;
      await tester.pumpAndSettle();
      expect(find.text('10,00 km'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      connection.dispose();
    },
  );
}
