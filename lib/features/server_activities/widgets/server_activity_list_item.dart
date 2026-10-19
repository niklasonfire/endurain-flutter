import 'package:endurain/features/activity/services/activity_stats_formatter_scope.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:endurain/features/server_activities/services/server_activity_formatter.dart';
import 'package:material_ui/material_ui.dart';

/// Mirrors the web list: sport icon, name, date/location, compact metrics.
class ServerActivityListItem extends StatelessWidget {
  const ServerActivityListItem({
    super.key,
    required this.activity,
    this.onTap,
    this.showSportIcon = true,
  });
  final ServerActivity activity;
  final VoidCallback? onTap;
  final bool showSportIcon;

  static bool usesPace(int type) => ServerActivityFormatter.usesPace(type);
  static bool isDistanceBased(int type) =>
      ServerActivityFormatter.isDistanceBased(type);
  static IconData sportIcon(int type) {
    if ({1, 2, 3, 34, 40}.contains(type)) return Icons.directions_run;
    if ({4, 5, 6, 7, 27, 28, 29, 35, 36}.contains(type)) {
      return Icons.directions_bike;
    }
    if ({8, 9}.contains(type)) return Icons.pool;
    if ({11, 12, 31, 44}.contains(type)) return Icons.hiking;
    if ({13, 32, 42, 43}.contains(type)) return Icons.rowing;
    if ({15, 16, 17}.contains(type)) return Icons.downhill_skiing;
    return Icons.fitness_center;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final formatter = context.statsFormatter;
    final locale = context.numberFormatLocale;
    final sportFormatter = ServerActivityFormatter(
      stats: formatter,
      l10n: l10n,
      locale: locale,
    );
    final duration = activity.timerSeconds ?? activity.elapsedSeconds;
    final metricParts = <String>[
      if (isDistanceBased(activity.activityType) &&
          activity.distanceMeters != null)
        sportFormatter.distance(
          activity.distanceMeters!,
          activity.activityType,
        ),
      if (duration != null) formatter.formatDuration(duration.round()),
      if (isDistanceBased(activity.activityType) &&
          activity.averageSpeedMetersPerSecond != null)
        sportFormatter.tempo(
          activity.averageSpeedMetersPerSecond!,
          activity.activityType,
        ),
      if (isDistanceBased(activity.activityType) &&
          activity.elevationGainMeters != null)
        '↗ ${formatter.formatElevation(activity.elevationGainMeters, locale: locale)}',
      if (!isDistanceBased(activity.activityType) && activity.calories != null)
        '${activity.calories!.round()} kcal',
      if (!isDistanceBased(activity.activityType) &&
          activity.averageHeartRate != null)
        formatter.labels.bpm('${activity.averageHeartRate!.round()}'),
    ];
    final place = [
      activity.city ?? activity.town,
      activity.country,
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
    final subtitle = [
      if (activity.startTime != null)
        DateFormat.yMMMd(locale).format(activity.startTime!.toLocal()),
      if (place.isNotEmpty) place,
    ].join(' · ');
    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSportIcon) ...[
                Tooltip(
                  message: l10n.serverActivitySport('${activity.activityType}'),
                  child: CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    child: Icon(sportIcon(activity.activityType)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name.isEmpty
                          ? l10n.serverActivitySport('${activity.activityType}')
                          : activity.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (metricParts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          metricParts.join(' · '),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
