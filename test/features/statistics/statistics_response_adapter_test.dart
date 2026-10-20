import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/statistics_response_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final invalidResponse = throwsA(
    isA<AppException>().having(
      (error) => error.code,
      'code',
      AppErrorCode.unexpectedResponseFormat,
    ),
  );

  test('duplicate sport aggregates fail instead of doubling distance', () {
    expect(
      () => StatisticsResponseAdapter.decode(
        _response([_sport(1, 5000), _sport(1, 5000)]),
        StatisticsPeriod.week,
      ),
      invalidResponse,
    );
  });

  test(
    'overflowing mixed-sport distance fails instead of displaying infinity',
    () {
      expect(
        () => StatisticsResponseAdapter.decode(
          _response([_sport(1, 1e308), _sport(4, 1e308)]),
          StatisticsPeriod.week,
        ),
        invalidResponse,
      );
    },
  );

  test(
    'distinct sports preserve distance exclusion for non-distance workouts',
    () {
      final data = StatisticsResponseAdapter.decode(
        _response([_sport(1, 5000), _sport(4, 20000), _sport(19, 1000)]),
        StatisticsPeriod.week,
      );
      expect(data.distanceMeters, 25000);
      expect(data.sports, hasLength(3));
    },
  );
}

Map<String, Object?> _response(List<Map<String, Object?>> sports) => {
  'total_distance': 26000,
  'total_duration': 7200,
  'total_elevation_gain': 100,
  'activity_count': 3,
  'breakdown': <Object?>[],
  'type_breakdown': sports,
};

Map<String, Object?> _sport(int id, double distance) => {
  'activity_type_id': id,
  'activity_type': 'Sport $id',
  'total_distance': distance,
  'total_duration': 2400,
  'total_elevation_gain': 0,
  'activity_count': 1,
};
