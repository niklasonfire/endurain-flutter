/// Read-only server activity. Measurements use SI units; unavailable values
/// stay null, so the UI can distinguish missing data from measured zero.
class ServerActivity {
  const ServerActivity({
    required this.id,
    required this.name,
    required this.activityType,
    this.startTime,
    this.distanceMeters,
    this.elapsedSeconds,
    this.timerSeconds,
    this.elevationGainMeters,
    this.averageHeartRate,
    this.averageSpeedMetersPerSecond,
    this.averagePower,
    this.calories,
    this.description,
    this.city,
    this.town,
    this.country,
  });

  final int id;
  final String name;
  final int activityType;
  final DateTime? startTime;
  final double? distanceMeters;
  final double? elapsedSeconds;
  final double? timerSeconds;
  final double? elevationGainMeters;
  final double? averageHeartRate;
  final double? averageSpeedMetersPerSecond;
  final double? averagePower;
  final double? calories;
  final String? description;
  final String? city;
  final String? town;
  final String? country;
}
