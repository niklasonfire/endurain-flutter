import 'package:endurain/features/achievements/models/achievement_models.dart';
import 'package:endurain/features/achievements/services/achievement_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

final origin = DateTime.utc(2026, 1, 1);
AchievementSample sample(double distance, int seconds, {int segment = 0}) =>
    AchievementSample(
      timestamp: origin.add(Duration(seconds: seconds)),
      distanceMeters: distance,
      segmentId: segment,
    );
AchievementActivity activity({
  int id = 1,
  int sport = 1,
  DateTime? start,
  double? distance,
  double? duration,
  double? elevation,
  List<AchievementSample> samples = const [],
}) => AchievementActivity(
  id: id,
  sportType: sport,
  fingerprint: '$id',
  startedAt: start ?? origin,
  distanceMeters: distance,
  durationSeconds: duration,
  elevationGainMeters: elevation,
  samples: samples,
);
void main() {
  test(
    'finds a fast kilometre inside a longer run with exact end interpolation',
    () {
      final result = const AchievementCalculator().analyze(
        activity(samples: [sample(0, 0), sample(500, 300), sample(2000, 600)]),
      );
      final record = result.candidates.singleWhere(
        (c) => c.targetDistanceMeters == 1000,
      );
      expect(record.value, 200);
      expect(record.effortStart, origin.add(const Duration(seconds: 300)));
      expect(record.effortEnd, origin.add(const Duration(seconds: 500)));
    },
  );
  test('summary records remain available without usable track data', () {
    final result = const AchievementCalculator().analyze(
      activity(distance: 12000, duration: 3600, elevation: 245),
    );
    expect(
      {for (final c in result.candidates) c.metric: c.value},
      {
        AchievementMetric.longestDistance: 12000,
        AchievementMetric.longestDuration: 3600,
        AchievementMetric.mostElevation: 245,
      },
    );
  });

  test(
    'calendar records respect UTC year filtering and server week starts',
    () {
      const calc = AchievementCalculator();
      final results = [
        calc.analyze(
          activity(
            id: 1,
            start: DateTime.utc(2025, 12, 31),
            distance: 9000,
            duration: 900,
          ),
        ),
        calc.analyze(
          activity(
            id: 2,
            start: DateTime.utc(2026, 1, 1),
            distance: 2000,
            duration: 200,
          ),
        ),
        calc.analyze(
          activity(
            id: 3,
            start: DateTime.utc(2026, 1, 3),
            distance: 3000,
            duration: 300,
          ),
        ),
        calc.analyze(
          activity(
            id: 4,
            sport: 2,
            start: DateTime.utc(2026, 1, 3),
            distance: 8000,
          ),
        ),
      ];
      final records = calc.records(
        results,
        year: 2026,
        firstDayOfWeek: DateTime.sunday,
      );
      final week = records.singleWhere(
        (r) =>
            r.winner.metric == AchievementMetric.weeklyDistance &&
            r.winner.sportType == 1,
      );
      expect(week.winner.value, 5000);
      expect(week.sourceActivityIds, [2, 3]);
      expect(week.periodStart, DateTime.utc(2026, 1, 1));
      expect(week.periodEnd, DateTime.utc(2026, 1, 4));
      expect(
        records
            .singleWhere(
              (r) => r.winner.metric == AchievementMetric.monthlyDuration,
            )
            .winner
            .value,
        500,
      );
    },
  );

  test(
    'a stop inside a kilometre counts but a stop before an effort does not',
    () {
      const calc = AchievementCalculator();
      final result = calc.analyze(
        activity(
          samples: [
            sample(0, 0),
            sample(500, 100),
            sample(500, 160),
            sample(1000, 260),
          ],
        ),
      );
      expect(
        result.candidates
            .singleWhere((c) => c.targetDistanceMeters == 1000)
            .value,
        260,
      );
      final short = result.candidates.singleWhere(
        (c) => c.targetDistanceMeters == 400,
      );
      expect(short.value, 80);
      expect(short.effortStart, origin);
      final after = calc.analyze(
        activity(
          samples: [
            sample(0, 0),
            sample(500, 300),
            sample(500, 360),
            sample(1000, 460),
          ],
        ),
      );
      final best = after.candidates.singleWhere(
        (c) => c.targetDistanceMeters == 400,
      );
      expect(best.value, 80);
      expect(best.effortStart, origin.add(const Duration(seconds: 360)));
    },
  );
  test('finds the optimum when a finish sample requires an interior start', () {
    final result = const AchievementCalculator().analyze(
      activity(
        samples: [
          sample(0, 0),
          sample(1500, 600),
          sample(2000, 700),
          sample(3000, 1700),
        ],
      ),
    );
    final best = result.candidates.singleWhere(
      (c) => c.targetDistanceMeters == 1000,
    );
    expect(best.value, 300);
    expect(best.effortStart, origin.add(const Duration(seconds: 400)));
    expect(best.effortEnd, origin.add(const Duration(seconds: 700)));
  });
  test('never bridges a segment boundary or invalid sample', () {
    const calc = AchievementCalculator();
    for (final samples in [
      [sample(0, 0), sample(600, 100), sample(1200, 200, segment: 1)],
      [
        sample(0, 0),
        sample(600, 100),
        sample(double.nan, 150),
        sample(1200, 200),
      ],
      [sample(0, 0), sample(600, 100), sample(1200, 90)],
      [sample(0, 0), sample(600, 100), sample(500, 200), sample(1200, 300)],
    ]) {
      expect(
        calc
            .analyze(activity(samples: samples))
            .candidates
            .where((c) => c.targetDistanceMeters == 1000),
        isEmpty,
      );
    }
  });
  test('exact ties choose earliest activity then numeric id independently of input order', () {
    const calc = AchievementCalculator();
    final older = calc.analyze(
      activity(id: 20, start: DateTime.utc(2025), distance: 1000),
    );
    final newer = calc.analyze(activity(id: 1, distance: 1000));
    final lowerId = calc.analyze(
      activity(id: 10, start: DateTime.utc(2025), distance: 1000),
    );
    for (final list in [
      [newer, older, lowerId],
      [lowerId, older, newer],
    ]) {
      expect(
        calc
            .records(list)
            .singleWhere(
              (r) => r.winner.metric == AchievementMetric.longestDistance,
            )
            .winner
            .activityId,
        10,
      );
    }
  });
  test('missing dates retain all-time records and never enter calendar or yearly records', () {
    const calc = AchievementCalculator();
    final analysis = calc.analyze(
      const AchievementActivity(
        id: 1,
        sportType: 1,
        fingerprint: 'x',
        distanceMeters: 1000,
      ),
    );
    expect(
      calc.records([analysis]).single.winner.metric,
      AchievementMetric.longestDistance,
    );
    expect(calc.records([analysis], year: 2026), isEmpty);
  });
  test('keeps sport variants separate and never infers efforts from summary averages', () {
    const calc = AchievementCalculator();
    final records = calc.records([
      calc.analyze(activity(id: 1, sport: 1, distance: 10000, duration: 1000)),
      calc.analyze(activity(id: 2, sport: 2, distance: 10000, duration: 900)),
      calc.analyze(activity(id: 3, sport: 35, distance: 10000, duration: 800)),
      calc.analyze(activity(id: 4, sport: 10, distance: 10000, duration: 700)),
    ]);
    expect(
      records.where(
        (r) => r.winner.metric == AchievementMetric.fastestDistance,
      ),
      isEmpty,
    );
    expect(
      records
          .where((r) => r.winner.metric == AchievementMetric.longestDistance)
          .map((r) => r.winner.sportType)
          .toSet(),
      {1, 2, 35},
    );
    expect(AchievementCalculator.distancesForSport(40), contains(1000));
    expect(AchievementCalculator.distancesForSport(36), contains(100000));
  });
}
