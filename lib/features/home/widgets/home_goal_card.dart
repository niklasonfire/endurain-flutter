import 'dart:math' as math;

import 'package:endurain/features/activity/services/activity_stats_formatter_scope.dart';
import 'package:endurain/features/goals/models/goal_progress.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class HomeGoalCard extends StatelessWidget {
  const HomeGoalCard({super.key, required this.goal});
  final GoalProgress goal;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final period = switch (goal.interval) {
      'daily' => l10n.homeGoalDaily,
      'weekly' => l10n.homeGoalWeekly,
      'monthly' => l10n.homeGoalMonthly,
      'yearly' => l10n.homeGoalYearly,
      _ => goal.interval,
    };
    final sport = switch (goal.activityType.toLowerCase()) {
      'run' => l10n.activityTypeRun,
      'bike' || 'ride' => l10n.activityTypeRide,
      'swim' => l10n.homeGoalSwim,
      'strength' => l10n.serverActivitySport('19'),
      'cardio' => l10n.serverActivitySport('41'),
      'walk' => l10n.activityTypeWalk,
      'hike' => l10n.activityTypeHike,
      _ => goal.activityType,
    };
    final metric = switch (goal.goalType) {
      'distance' => l10n.activityStatDistance,
      'duration' => l10n.activityStatDuration,
      'elevation' => l10n.activityStatElevationGain,
      'activities' => l10n.statsCount,
      'calories' => l10n.homeGoalCalories,
      _ => goal.goalType,
    };
    final locale = context.numberFormatLocale;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$sport · $period', style: theme.textTheme.titleSmall),
            Text(
              '${DateFormat.MMMd(locale).format(goal.startDate)} – ${DateFormat.yMMMd(locale).format(goal.endDate)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Text(metric, style: theme.textTheme.bodySmall),
            Text(
              '${_value(context, goal.achieved)} / ${_value(context, goal.target)}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Semantics(
              label: '$sport · $metric',
              value: NumberFormat.decimalPercentPattern(
                locale: locale,
                decimalDigits: 0,
              ).format(goal.progress),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              goal.isAchieved
                  ? l10n.homeGoalAchieved
                  : l10n.homeGoalRemaining(
                      _value(context, math.max(0, goal.target - goal.achieved)),
                    ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: goal.isAchieved
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _value(BuildContext context, double value) {
    final formatter = context.statsFormatter;
    final locale = context.numberFormatLocale;
    return switch (goal.goalType) {
      'distance' => formatter.formatDistance(value, locale: locale),
      'elevation' => formatter.formatElevation(value, locale: locale),
      'duration' => formatter.formatDuration(value.floor()),
      'calories' =>
        '${NumberFormat.decimalPattern(locale).format(value.round())} kcal',
      _ => NumberFormat.decimalPattern(locale).format(value.round()),
    };
  }
}
