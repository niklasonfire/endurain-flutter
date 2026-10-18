import 'package:endurain/features/statistics/models/activity_statistics.dart';

abstract interface class StatisticsRepository {
  Future<ActivityStatistics> fetch(StatisticsQuery query);
}
