/// SI units throughout; sports retain the server's original numeric type.
enum AchievementMetric {
  fastestDistance,
  longestDistance,
  longestDuration,
  mostElevation,
  weeklyDistance,
  weeklyDuration,
  monthlyDistance,
  monthlyDuration,
}

enum AchievementDistanceSource { recorded, gps, summary }

class AchievementSample {
  const AchievementSample({
    required this.timestamp,
    required this.distanceMeters,
    this.segmentId = 0,
  });
  final DateTime timestamp;
  final double distanceMeters;

  /// Adapter-assigned continuity identifier: pauses, gaps and invalid fixes split it.
  final int segmentId;
}

class AchievementActivity {
  const AchievementActivity({
    required this.id,
    required this.sportType,
    required this.fingerprint,
    this.startedAt,
    this.distanceMeters,
    this.durationSeconds,
    this.elevationGainMeters,
    this.samples = const [],
    this.distanceSource = AchievementDistanceSource.recorded,
  });
  final int id;
  final int sportType;
  final String fingerprint;
  final DateTime? startedAt;
  final double? distanceMeters;

  /// Server timer duration, matching Statistics; effort records use elapsed time.
  final double? durationSeconds;
  final double? elevationGainMeters;
  final List<AchievementSample> samples;
  final AchievementDistanceSource distanceSource;
}

class AchievementCandidate {
  const AchievementCandidate({
    required this.activityId,
    required this.sportType,
    required this.metric,
    required this.value,
    required this.startedAt,
    this.targetDistanceMeters,
    this.effortStart,
    this.effortEnd,
    this.distanceSource = AchievementDistanceSource.summary,
  });
  final int activityId;
  final int sportType;
  final AchievementMetric metric;
  final double value;
  final DateTime? startedAt;
  final double? targetDistanceMeters;
  final DateTime? effortStart;
  final DateTime? effortEnd;
  final AchievementDistanceSource distanceSource;
}

class AchievementAnalysis {
  const AchievementAnalysis({
    required this.activity,
    required this.candidates,
    required this.calculationVersion,
  });
  final AchievementActivity activity;
  final List<AchievementCandidate> candidates;
  final int calculationVersion;
}

class AchievementRecord {
  const AchievementRecord({
    required this.winner,
    required this.sourceActivityIds,
    this.year,
    this.periodStart,
    this.periodEnd,
  });
  final AchievementCandidate winner;
  final List<int> sourceActivityIds;
  final int? year;

  /// UTC calendar boundaries, end exclusive. Null for individual records.
  final DateTime? periodStart;
  final DateTime? periodEnd;
}
