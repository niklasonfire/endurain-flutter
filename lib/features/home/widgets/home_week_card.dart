import 'dart:math' as math;

import 'package:endurain/features/activity/services/activity_stats_formatter_scope.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class HomeWeekCard extends StatelessWidget {
  const HomeWeekCard({
    super.key,
    required this.statistics,
    required this.anchor,
    required this.loading,
    required this.error,
  });
  final ActivityStatistics? statistics;
  final DateTime anchor;
  final bool loading;
  final bool error;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final formatter = context.statsFormatter;
    final data = statistics;
    final buckets = data?.buckets ?? const <StatisticsBucket>[];
    final firstDay = buckets.length == 7 ? buckets.first.index : 0;
    final date = DateTime.utc(anchor.year, anchor.month, anchor.day);
    final start = date.subtract(
      Duration(days: (date.weekday - 1 - firstDay + 7) % 7),
    );
    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    final activeDays = buckets.where((b) => b.metrics.count > 0).length;
    final values = List.generate(
      7,
      (i) => buckets
          .where((b) => b.index == (firstDay + i) % 7)
          .fold<double>(0, (sum, b) => sum + b.metrics.durationSeconds),
    );
    final maximum = values.fold<double>(1, math.max);
    final locale = context.numberFormatLocale;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.homeWeek, style: theme.textTheme.titleLarge),
            Text(
              '${DateFormat.MMMd(locale).format(start)} – ${DateFormat.yMMMd(locale).format(days.last)}',
              style: theme.textTheme.bodySmall,
            ),
            if (loading) const AdaptiveProgressBar(),
            if (error)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.homeLoadFailed),
              ),
            if (data != null) ...[
              const SizedBox(height: 18),
              Text(
                formatter.formatDuration(data.totals.durationSeconds.floor()),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(l10n.homeActiveTime, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(l10n.homeActivitiesCount(data.totals.count)),
                  Text(
                    formatter.formatDistance(
                      data.distanceMeters,
                      locale: locale,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 108,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    7,
                    (i) => Expanded(
                      child: Semantics(
                        label:
                            '${DateFormat.EEEE(locale).format(days[i])}: ${formatter.formatDuration(values[i].floor())}',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 25,
                              height: values[i] > 0
                                  ? math.max(6, 108 * values[i] / maximum)
                                  : 3,
                              decoration: BoxDecoration(
                                color: values[i] > 0
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ExcludeSemantics(
                child: Row(
                  children: List.generate(
                    7,
                    (i) => Expanded(
                      child: Text(
                        DateFormat.E(locale).format(days[i]),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.homeDailyTime, style: theme.textTheme.bodySmall),
              if (activeDays > 0)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.homeActiveDays(activeDays),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              if (data.totals.count == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(l10n.homeNoActivities),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
