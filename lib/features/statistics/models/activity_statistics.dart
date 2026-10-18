import 'package:endurain/features/server_activities/services/server_activity_formatter.dart';

enum StatisticsPeriod { week, month, year }

class StatisticsQuery {
  StatisticsQuery({
    this.period = StatisticsPeriod.week,
    DateTime? date,
    this.sport,
  }) : date = date ?? DateTime.now().toUtc();
  final StatisticsPeriod period;
  final DateTime date;
  final StatisticsSport? sport;
}

class StatisticsMetrics {
  const StatisticsMetrics({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.elevationMeters,
    required this.count,
  });
  final double distanceMeters;
  final double durationSeconds;
  final double elevationMeters;
  final int count;
  static const zero = StatisticsMetrics(
    distanceMeters: 0,
    durationSeconds: 0,
    elevationMeters: 0,
    count: 0,
  );
}

class StatisticsSport {
  const StatisticsSport({
    required this.id,
    required this.apiName,
    required this.metrics,
  });
  final int id;
  final String apiName;
  final StatisticsMetrics metrics;
  bool get hasDistance => ServerActivityFormatter.isDistanceBased(id);
}

class StatisticsBucket {
  const StatisticsBucket(this.index, this.metrics);
  final int index;
  final StatisticsMetrics metrics;
}

class ActivityStatistics {
  const ActivityStatistics({
    required this.totals,
    required this.buckets,
    required this.sports,
  });
  final StatisticsMetrics totals;
  final List<StatisticsBucket> buckets;
  final List<StatisticsSport> sports;
  // Only complete per-sport server aggregates contribute to mixed-sport distance.
  double get distanceMeters => sports
      .where((s) => s.hasDistance)
      .fold(0, (sum, sport) => sum + sport.metrics.distanceMeters);
  static const empty = ActivityStatistics(
    totals: StatisticsMetrics.zero,
    buckets: [],
    sports: [],
  );
}
