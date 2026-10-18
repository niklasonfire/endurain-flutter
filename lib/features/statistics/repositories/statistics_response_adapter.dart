import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';

/// Strict wire boundary: missing metrics never become plausible zero totals.
class StatisticsResponseAdapter {
  static ActivityStatistics decode(Object? response, StatisticsPeriod period) {
    final data = _object(response);
    final buckets = data['breakdown'];
    final sports = data['type_breakdown'];
    if (buckets is! List || sports is! List) _invalid();
    final key = switch (period) {
      StatisticsPeriod.week => 'day_of_week',
      StatisticsPeriod.month => 'week_number',
      StatisticsPeriod.year => 'month_number',
    };
    final seen = <int>{};
    return ActivityStatistics(
      totals: _metrics(data),
      buckets: List.unmodifiable(
        buckets.map((row) {
          final object = _object(row);
          final index = _integer(object[key]);
          final valid = switch (period) {
            StatisticsPeriod.week => index >= 0 && index <= 6,
            StatisticsPeriod.month => index >= 1 && index <= 6,
            StatisticsPeriod.year => index >= 1 && index <= 12,
          };
          if (!valid || !seen.add(index)) _invalid();
          return StatisticsBucket(index, _metrics(object));
        }),
      ),
      sports: List.unmodifiable(
        sports.map((row) {
          final object = _object(row);
          final id = _integer(object['activity_type_id']);
          final name = object['activity_type'];
          if (id < 1 || name is! String || name.trim().isEmpty) _invalid();
          return StatisticsSport(
            id: id,
            apiName: name,
            metrics: _metrics(object),
          );
        }),
      ),
    );
  }

  static Map<String, dynamic> _object(Object? value) {
    if (value is! Map<String, dynamic>) _invalid();
    return value;
  }

  static double _number(Object? value) {
    if (value is! num || !value.isFinite || value < 0) _invalid();
    return value.toDouble();
  }

  static int _integer(Object? value) {
    if (value is! int || value < 0) _invalid();
    return value;
  }

  static StatisticsMetrics _metrics(Map<String, dynamic> data) =>
      StatisticsMetrics(
        distanceMeters: _number(data['total_distance']),
        durationSeconds: _number(data['total_duration']),
        elevationMeters: _number(data['total_elevation_gain']),
        count: _integer(data['activity_count']),
      );
  static Never _invalid() =>
      throw const AppException(AppErrorCode.unexpectedResponseFormat);
}
