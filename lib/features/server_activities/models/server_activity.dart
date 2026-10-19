import 'package:endurain/features/server_activities/models/server_activity_start_time.dart';

/// Read-only server activity. Measurements use SI units; unavailable values
/// stay null, so the UI can distinguish missing data from measured zero.
class ServerActivity {
  const ServerActivity({
    required this.id,
    required this.name,
    required this.activityType,
    this.startTime,
    this.displayStartTime,
    this.distanceMeters,
    this.elapsedSeconds,
    this.timerSeconds,
    this.elevationGainMeters,
    this.averageHeartRate,
    this.averageSpeedMetersPerSecond,
    this.paceSecondsPerMeter,
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

  /// Absolute start instant, only when the server supplied an explicit offset.
  final DateTime? startTime;
  final ServerActivityStartTime? displayStartTime;
  final double? distanceMeters;
  final double? elapsedSeconds;
  final double? timerSeconds;
  final double? elevationGainMeters;
  final double? averageHeartRate;
  final double? averageSpeedMetersPerSecond;

  /// Server-computed average pace; independent of mean GPS sample speed.
  final double? paceSecondsPerMeter;
  final double? averagePower;
  final double? calories;
  final String? description;
  final String? city;
  final String? town;
  final String? country;
}
