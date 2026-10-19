import 'package:endurain/features/achievements/models/achievement_models.dart';
import 'package:endurain/features/activity/services/activity_stats_formatter_scope.dart';
import 'package:endurain/features/server_activities/screens/server_activity_detail_screen.dart';
import 'package:endurain/features/server_activities/services/server_activity_formatter.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class AchievementRecordCard extends StatelessWidget {
  const AchievementRecordCard({super.key, required this.record});
  final AchievementRecord record;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final winner = record.winner;
    final stats = context.statsFormatter;
    final locale = context.numberFormatLocale;
    final format = ServerActivityFormatter(
      stats: stats,
      l10n: l,
      locale: locale,
    );
    final title = switch (winner.metric) {
      AchievementMetric.fastestDistance => l.achievementsFastest(
        _target(winner.targetDistanceMeters!, locale, l),
      ),
      AchievementMetric.longestDistance => l.achievementsLongestDistance,
      AchievementMetric.longestDuration => l.achievementsLongestDuration,
      AchievementMetric.mostElevation => l.achievementsElevation,
      AchievementMetric.weeklyDistance => l.achievementsWeeklyDistance,
      AchievementMetric.weeklyDuration => l.achievementsWeeklyDuration,
      AchievementMetric.monthlyDistance => l.achievementsMonthlyDistance,
      AchievementMetric.monthlyDuration => l.achievementsMonthlyDuration,
    };
    final value = switch (winner.metric) {
      AchievementMetric.fastestDistance ||
      AchievementMetric.longestDuration ||
      AchievementMetric.weeklyDuration ||
      AchievementMetric.monthlyDuration => stats.formatDuration(
        winner.value.round(),
      ),
      AchievementMetric.mostElevation => stats.formatElevation(
        winner.value,
        locale: locale,
      ),
      _ => format.distance(winner.value, winner.sportType),
    };
    final period = record.periodStart != null && record.periodEnd != null;
    final dateFormat = DateFormat.yMMMd(locale);
    final date = period
        ? '${dateFormat.format(record.periodStart!)} – ${dateFormat.format(record.periodEnd!.subtract(const Duration(days: 1)))} (UTC)'
        : winner.startedAt == null
        ? l.achievementsMissingDate
        : dateFormat.format(winner.startedAt!.toLocal());
    final partialWeek =
        period &&
        (winner.metric == AchievementMetric.weeklyDistance ||
            winner.metric == AchievementMetric.weeklyDuration) &&
        record.periodEnd!.difference(record.periodStart!).inDays < 7;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.serverActivitySport('${winner.sportType}'),
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            if (winner.metric == AchievementMetric.fastestDistance)
              Text(
                format.tempo(
                  winner.targetDistanceMeters! / winner.value,
                  winner.sportType,
                ),
              ),
            Text(date),
            if (partialWeek) Text(l.achievementsPartialWeek),
            Text(switch (winner.distanceSource) {
              AchievementDistanceSource.gps => l.achievementsGpsEstimate,
              AchievementDistanceSource.recorded =>
                l.achievementsRecordedDistance,
              AchievementDistanceSource.summary => l.achievementsServerSummary,
            }, style: Theme.of(context).textTheme.bodySmall),
            if (period)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(l.achievementsContributors),
                children: [
                  for (final id in record.sourceActivityIds)
                    ListTile(
                      title: Text(l.achievementsActivity('$id')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _open(context, id),
                    ),
                ],
              )
            else
              TextButton(
                onPressed: () => _open(context, winner.activityId),
                child: Text(l.achievementsActivity('${winner.activityId}')),
              ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, int id) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ServerActivityDetailScreen(
        activityId: id,
        effortStart: record.periodStart == null
            ? record.winner.effortStart
            : null,
        effortEnd: record.periodStart == null ? record.winner.effortEnd : null,
      ),
    ),
  );
  // Target distances identify the achievement itself and stay fixed when display
  // preferences change (a fastest mile must not turn into a 1.61 km category).
  String _target(double meters, String locale, AppLocalizations l) =>
      meters == 1609.344
      ? l.unitMile(NumberFormat('0', locale).format(1))
      : meters < 1000
      ? l.unitMeter(NumberFormat('0', locale).format(meters))
      : l.unitKilometer(NumberFormat('0.###', locale).format(meters / 1000));
}
