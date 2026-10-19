import 'package:endurain/features/achievements/models/achievement_models.dart';

/// Pure, rebuildable record calculation. Inputs must be full-resolution streams.
class AchievementCalculator {
  const AchievementCalculator();
  static const calculationVersion = 1;
  static const runningDistances = <double>[
    400,
    1000,
    1609.344,
    5000,
    10000,
    21097.5,
    42195,
  ];
  static const cyclingDistances = <double>[5000, 10000, 20000, 40000, 100000];
  static bool isRunning(int sportType) => {1, 2, 3, 34, 40}.contains(sportType);
  static bool isCycling(int sportType) =>
      {4, 5, 6, 7, 27, 28, 29, 35, 36}.contains(sportType);
  static List<double> distancesForSport(int sportType) => isRunning(sportType)
      ? runningDistances
      : isCycling(sportType)
      ? cyclingDistances
      : const [];

  static bool isDistanceSport(int sportType) => !{
    10,
    14,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    39,
    41,
    46,
    47,
  }.contains(sportType);

  AchievementAnalysis analyze(AchievementActivity activity) {
    final candidates = <AchievementCandidate>[];
    final summary = {
      AchievementMetric.longestDistance: isDistanceSport(activity.sportType)
          ? activity.distanceMeters
          : null,
      AchievementMetric.longestDuration: activity.durationSeconds,
      AchievementMetric.mostElevation: activity.elevationGainMeters,
    };
    for (final entry in summary.entries) {
      final value = entry.value;
      if (value != null && value.isFinite && value > 0) {
        candidates.add(
          AchievementCandidate(
            activityId: activity.id,
            sportType: activity.sportType,
            metric: entry.key,
            value: value,
            startedAt: activity.startedAt?.toUtc(),
          ),
        );
      }
    }
    for (final target in distancesForSport(activity.sportType)) {
      AchievementCandidate? best;
      for (final segment in _segments(activity.samples)) {
        final candidate = _fastest(activity, segment, target);
        if (candidate != null &&
            (best == null || _compare(candidate, best) < 0)) {
          best = candidate;
        }
      }
      if (best != null) candidates.add(best);
    }
    return AchievementAnalysis(
      activity: activity,
      candidates: List.unmodifiable(candidates),
      calculationVersion: calculationVersion,
    );
  }

  /// Select current-version records using the account calendar when available.
  /// Missing/invalid calendars suppress weekly records rather than guessing.
  List<AchievementRecord> selectRecords(
    Iterable<AchievementAnalysis> analyses, {
    int? year,
    int? sportType,
    int? firstDayOfWeek,
  }) {
    final hasCalendar =
        firstDayOfWeek != null && firstDayOfWeek >= 1 && firstDayOfWeek <= 7;
    return List.unmodifiable(
      records(
        analyses.where(
          (analysis) =>
              analysis.calculationVersion == calculationVersion &&
              (sportType == null || analysis.activity.sportType == sportType),
        ),
        year: year,
        firstDayOfWeek: hasCalendar ? firstDayOfWeek : DateTime.monday,
      ).where(
        (record) =>
            hasCalendar ||
            (record.winner.metric != AchievementMetric.weeklyDistance &&
                record.winner.metric != AchievementMetric.weeklyDuration),
      ),
    );
  }

  List<AchievementRecord> records(
    Iterable<AchievementAnalysis> analyses, {
    int? year,
    int firstDayOfWeek = DateTime.monday,
  }) {
    if (firstDayOfWeek < 1 || firstDayOfWeek > 7) {
      throw ArgumentError.value(firstDayOfWeek, 'firstDayOfWeek');
    }
    final activities = <int, AchievementAnalysis>{
      for (final analysis in analyses) analysis.activity.id: analysis,
    };
    final winners = <String, AchievementRecord>{};
    final periods = <String, _PeriodTotal>{};
    void consider(AchievementRecord record) {
      final c = record.winner;
      final key = '${c.sportType}/${c.metric.name}/${c.targetDistanceMeters}';
      final previous = winners[key];
      if (previous == null || _compare(c, previous.winner) < 0) {
        winners[key] = record;
      }
    }

    for (final analysis in activities.values) {
      final activity = analysis.activity;
      final start = activity.startedAt?.toUtc();
      if (year != null && start?.year != year) continue;
      for (final candidate in analysis.candidates) {
        consider(
          AchievementRecord(
            winner: candidate,
            sourceActivityIds: [activity.id],
            year: year,
          ),
        );
      }
      if (start == null) continue;
      final day = DateTime.utc(start.year, start.month, start.day);
      for (final weekly in [true, false]) {
        var begin = weekly
            ? day.subtract(Duration(days: (day.weekday - firstDayOfWeek) % 7))
            : DateTime.utc(day.year, day.month);
        var end = weekly
            ? begin.add(const Duration(days: 7))
            : DateTime.utc(day.year, day.month + 1);
        if (year != null) {
          final yearBegin = DateTime.utc(year);
          final yearEnd = DateTime.utc(year + 1);
          if (begin.isBefore(yearBegin)) begin = yearBegin;
          if (end.isAfter(yearEnd)) end = yearEnd;
        }
        final metrics = {
          (weekly
                  ? AchievementMetric.weeklyDistance
                  : AchievementMetric.monthlyDistance):
              isDistanceSport(activity.sportType)
              ? activity.distanceMeters
              : null,
          (weekly
                  ? AchievementMetric.weeklyDuration
                  : AchievementMetric.monthlyDuration):
              activity.durationSeconds,
        };
        for (final entry in metrics.entries) {
          final value = entry.value;
          if (value == null || !value.isFinite || value <= 0) continue;
          final key =
              '${activity.sportType}/${entry.key.name}/${begin.microsecondsSinceEpoch}';
          final total = periods.putIfAbsent(
            key,
            () => _PeriodTotal(begin, end, activity.sportType, entry.key),
          );
          total.value += value;
          total.ids.add(activity.id);
        }
      }
    }
    for (final total in periods.values) {
      total.ids.sort();
      consider(
        AchievementRecord(
          winner: AchievementCandidate(
            activityId: total.ids.first,
            sportType: total.sport,
            metric: total.metric,
            value: total.value,
            startedAt: total.start,
          ),
          sourceActivityIds: List.unmodifiable(total.ids),
          year: year,
          periodStart: total.start,
          periodEnd: total.end,
        ),
      );
    }
    final keys = winners.keys.toList()..sort();
    return List.unmodifiable(keys.map((key) => winners[key]!));
  }

  Iterable<List<AchievementSample>> _segments(
    List<AchievementSample> samples,
  ) sync* {
    var current = <AchievementSample>[];
    for (final sample in samples) {
      if (!sample.distanceMeters.isFinite || sample.distanceMeters < 0) {
        if (current.length > 1) yield current;
        current = [];
        continue;
      }
      if (current.isNotEmpty &&
          (sample.segmentId != current.last.segmentId ||
              !sample.timestamp.isAfter(current.last.timestamp) ||
              sample.distanceMeters < current.last.distanceMeters)) {
        if (current.length > 1) yield current;
        current = [];
      }
      current.add(sample);
    }
    if (current.length > 1) yield current;
  }

  AchievementCandidate? _fastest(
    AchievementActivity activity,
    List<AchievementSample> samples,
    double target,
  ) {
    final minimum = samples.first.distanceMeters;
    final maximum = samples.last.distanceMeters - target;
    if (maximum < minimum) return null;
    AchievementCandidate? best;
    // Duration as a function of start distance is piecewise linear. Its minima
    // occur where either boundary meets a sample, including interior starts.
    for (final endsAtSample in [false, true]) {
      var left = 0;
      var right = 0;
      for (final sample in samples) {
        final startDistance =
            sample.distanceMeters - (endsAtSample ? target : 0);
        if (startDistance < minimum || startDistance > maximum) continue;
        final endDistance = startDistance + target;
        // Latest start on a stationary plateau; earliest finish on a plateau.
        while (left + 1 < samples.length &&
            samples[left + 1].distanceMeters <= startDistance) {
          left++;
        }
        while (right + 1 < samples.length &&
            samples[right + 1].distanceMeters < endDistance) {
          right++;
        }
        final start = _timeAt(samples, left, startDistance);
        final end = _timeAt(samples, right, endDistance);
        final seconds = (end - start) / Duration.microsecondsPerSecond;
        if (seconds <= 0 || !seconds.isFinite) continue;
        final candidate = AchievementCandidate(
          activityId: activity.id,
          sportType: activity.sportType,
          metric: AchievementMetric.fastestDistance,
          targetDistanceMeters: target,
          value: seconds,
          startedAt: activity.startedAt?.toUtc(),
          effortStart: DateTime.fromMicrosecondsSinceEpoch(
            start.round(),
            isUtc: true,
          ),
          effortEnd: DateTime.fromMicrosecondsSinceEpoch(
            end.round(),
            isUtc: true,
          ),
          distanceSource: activity.distanceSource,
        );
        if (best == null || _compare(candidate, best) < 0) best = candidate;
      }
    }
    return best;
  }

  double _timeAt(List<AchievementSample> samples, int index, double distance) {
    final a = samples[index];
    if (distance == a.distanceMeters) {
      return a.timestamp.microsecondsSinceEpoch.toDouble();
    }
    final b = samples[index + 1];
    final fraction =
        (distance - a.distanceMeters) / (b.distanceMeters - a.distanceMeters);
    return a.timestamp.microsecondsSinceEpoch +
        b.timestamp.difference(a.timestamp).inMicroseconds * fraction;
  }

  int _compare(AchievementCandidate a, AchievementCandidate b) {
    final value = a.metric == AchievementMetric.fastestDistance
        ? a.value.compareTo(b.value)
        : b.value.compareTo(a.value);
    if (value != 0) return value;
    final date = _dateCompare(a.startedAt, b.startedAt);
    if (date != 0) return date;
    final id = a.activityId.compareTo(b.activityId);
    return id != 0 ? id : _dateCompare(a.effortStart, b.effortStart);
  }

  int _dateCompare(DateTime? a, DateTime? b) => a == null
      ? (b == null ? 0 : 1)
      : b == null
      ? -1
      : a.compareTo(b);
}

class _PeriodTotal {
  _PeriodTotal(this.start, this.end, this.sport, this.metric);
  final DateTime start;
  final DateTime end;
  final int sport;
  final AchievementMetric metric;
  double value = 0;
  final List<int> ids = [];
}
