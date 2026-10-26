import 'package:endurain/features/statistics/models/activity_statistics.dart';

abstract interface class StatisticsRepository {
  Future<ActivityStatistics> fetch(StatisticsQuery query);
}

/// Raw server payload source of the statistics summaries, for cache-through
/// decorators (ADR-0001): the decorator fetches the envelope, stores it raw,
/// and re-parses it with ApiStatisticsRepository when serving offline.
abstract interface class StatisticsRawSource {
  /// Decoded activities-summaries object exactly as returned by the server.
  Future<Object?> fetchStatisticsEnvelope(StatisticsQuery query);
}
