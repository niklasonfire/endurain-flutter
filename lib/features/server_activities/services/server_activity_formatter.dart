import 'package:endurain/core/models/measurement_system.dart';
import 'package:endurain/features/activity/services/activity_stats_formatter.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:intl/intl.dart';

/// Web-compatible sport-specific units, layered over the app's SI formatter.
class ServerActivityFormatter {
  const ServerActivityFormatter({
    required this.stats,
    required this.l10n,
    required this.locale,
  });
  final ActivityStatsFormatter stats;
  final AppLocalizations l10n;
  final String locale;

  static bool usesPace(int type) =>
      {1, 2, 3, 8, 9, 11, 12, 13, 31, 32, 34, 40, 42, 44}.contains(type);
  static bool isDistanceBased(int type) => !{
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
  }.contains(type);

  String distance(double meters, int type) {
    if (type == 8 || type == 9) {
      final imperial = stats.system == MeasurementSystem.imperial;
      final value = NumberFormat.decimalPattern(locale)
          .format((imperial ? meters / 0.9144 : meters).round());
      return imperial
          ? l10n.serverActivityUnitYard(value)
          : stats.labels.meter(value);
    }
    return stats.formatDistance(meters, locale: locale);
  }

  /// Summary pace comes from the server's seconds/metre value, not from the
  /// average of GPS sample speeds. Older servers may omit it; elapsed time
  /// over total distance provides the equivalent aggregate fallback.
  String? activityTempo(ServerActivity activity) {
    if (!usesPace(activity.activityType)) {
      final speed = activity.averageSpeedMetersPerSecond;
      return speed == null || !speed.isFinite || speed < 0
          ? null
          : tempo(speed, activity.activityType);
    }
    var pace = activity.paceSecondsPerMeter;
    if (pace == null || !pace.isFinite || pace <= 0) {
      final duration = activity.elapsedSeconds ?? activity.timerSeconds;
      final distance = activity.distanceMeters;
      if (duration == null ||
          !duration.isFinite ||
          duration <= 0 ||
          distance == null ||
          !distance.isFinite ||
          distance <= 0) {
        return null;
      }
      pace = duration / distance;
    }
    final imperial = stats.system == MeasurementSystem.imperial;
    final swimming = activity.activityType == 8 || activity.activityType == 9;
    final rowing = {13, 32, 42}.contains(activity.activityType);
    final meters = swimming
        ? (imperial ? 91.44 : 100)
        : rowing
        ? 500
        : (imperial ? 1609.34 : 1000);
    final displaySeconds = pace * meters;
    if (!displaySeconds.isFinite) return null;
    final seconds = displaySeconds.round();
    final clock =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    if (swimming) {
      return imperial
          ? l10n.serverActivityUnitMinutesPer100Yards(clock)
          : l10n.serverActivityUnitMinutesPer100Meters(clock);
    }
    if (rowing) {
      return l10n.serverActivityUnitMinutesPer500Meters(clock);
    }
    return imperial
        ? stats.labels.minutesPerMile(clock)
        : stats.labels.minutesPerKilometer(clock);
  }

  String tempo(double speed, int type) {
    if (usesPace(type)) {
      if (speed <= 0) return '—';
      if (type == 8 || type == 9) {
        final imperial = stats.system == MeasurementSystem.imperial;
        final pace = stats.formatDuration(
          ((imperial ? 91.44 : 100) / speed).round(),
        );
        return imperial
            ? l10n.serverActivityUnitMinutesPer100Yards(pace)
            : l10n.serverActivityUnitMinutesPer100Meters(pace);
      }
      if ({13, 32, 42}.contains(type)) {
        return l10n.serverActivityUnitMinutesPer500Meters(
          stats.formatDuration((500 / speed).round()),
        );
      }
      return stats.formatPace(speed);
    }
    if (type == 30 || type == 43) {
      return l10n.serverActivityUnitKnots(
        NumberFormat('0.00', locale).format(speed * 3600 / 1852),
      );
    }
    return stats.formatSpeed(speed, locale: locale);
  }
}
