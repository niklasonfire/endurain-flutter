import 'dart:async';
import 'dart:math' as math;

import 'package:endurain/core/services/app_scope.dart';
import 'package:endurain/features/activity/services/activity_stats_formatter_scope.dart';
import 'package:endurain/features/server_activities/services/server_activity_formatter.dart';
import 'package:endurain/features/statistics/controllers/statistics_controller.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';
import 'package:endurain/shared/state/owned_controllers.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, this.controller, this.onSignIn});
  final StatisticsController? controller;
  final VoidCallback? onSignIn;
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with OwnedControllers, WidgetsBindingObserver {
  late final StatisticsController _controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = registerController(
      widget.controller,
      () => AppScope.servicesOf(
        context,
        listen: false,
      ).createStatisticsController(),
    );
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    if (widget.controller == null) {
      await AppScope.servicesOf(
        context,
        listen: false,
      ).authSession.readSession();
    }
    if (mounted && !_controller.isLoading) await _controller.refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_initialize());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _set({
    StatisticsPeriod? period,
    DateTime? date,
    StatisticsSport? sport,
    bool changeSport = false,
  }) {
    final query = _controller.query;
    unawaited(
      _controller.setQuery(
        StatisticsQuery(
          period: period ?? query.period,
          date: date ?? query.date,
          sport: changeSport ? sport : query.sport,
        ),
      ),
    );
  }

  DateTime _shift(int direction) {
    final query = _controller.query;
    final d = query.date;
    return switch (query.period) {
      StatisticsPeriod.week => DateTime.utc(
        d.year,
        d.month,
        d.day + direction * 7,
      ),
      StatisticsPeriod.month => DateTime.utc(d.year, d.month + direction, 1),
      StatisticsPeriod.year => DateTime.utc(d.year + direction, 1, 1),
    };
  }

  bool get _canNext {
    final next = _shift(1);
    final now = DateTime.now().toUtc();
    return !next.isAfter(DateTime.utc(now.year, now.month, now.day));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveScaffold(
      title: l10n.statsTab,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isGuest) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.statsGuest, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    AdaptiveButton(
                      onPressed: widget.onSignIn,
                      label: l10n.serverActivitiesSignIn,
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _filters(l10n),
                if (_controller.isLoading) const LinearProgressIndicator(),
                if (_controller.error != null) ...[
                  Text(l10n.statsLoadFailed, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: _controller.refresh,
                    child: Text(l10n.serverActivitiesRetry),
                  ),
                ],
                if (_controller.statistics case final data?)
                  ..._content(data, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filters(AppLocalizations l10n) {
    final query = _controller.query;
    final locale = context.numberFormatLocale;
    final date = query.date;
    final title = switch (query.period) {
      StatisticsPeriod.week => l10n.statsWeekContaining(
        DateFormat.yMMMd(locale).format(date),
      ),
      StatisticsPeriod.month => DateFormat.yMMMM(locale).format(date),
      StatisticsPeriod.year => DateFormat.y(locale).format(date),
    };
    final sports = <int, StatisticsSport>{
      for (final sport in _controller.statistics?.sports ?? <StatisticsSport>[])
        sport.id: sport,
      if (query.sport != null) query.sport!.id: query.sport!,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final period in StatisticsPeriod.values)
              ChoiceChip(
                label: Text(switch (period) {
                  StatisticsPeriod.week => l10n.statsWeek,
                  StatisticsPeriod.month => l10n.statsMonth,
                  StatisticsPeriod.year => l10n.statsYear,
                }),
                selected: query.period == period,
                onSelected: (_) => _set(period: period),
              ),
          ],
        ),
        Row(
          children: [
            IconButton(
              tooltip: l10n.statsPrevious,
              onPressed: date.year > 1900 ? () => _set(date: _shift(-1)) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: l10n.statsNext,
              onPressed: _canNext ? () => _set(date: _shift(1)) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        DropdownButton<int>(
          value: query.sport?.id ?? 0,
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: 0,
              child: Text(l10n.serverActivitiesAllSports),
            ),
            for (final sport in sports.values)
              DropdownMenuItem(
                value: sport.id,
                child: Text(l10n.serverActivitySport('${sport.id}')),
              ),
          ],
          onChanged: (id) => _set(sport: sports[id], changeSport: true),
        ),
        Text(
          l10n.statsCalendarNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _content(ActivityStatistics data, AppLocalizations l10n) {
    final format = context.statsFormatter;
    final locale = context.numberFormatLocale;
    final sport = _controller.query.sport;
    final distance = sport == null || sport.hasDistance;
    final distanceValue = sport == null
        ? data.distanceMeters
        : data.totals.distanceMeters;
    final formatter = ServerActivityFormatter(
      stats: format,
      l10n: l10n,
      locale: locale,
    );
    final values = <(String, String)>[
      if (distance)
        (
          l10n.statsDistance,
          sport == null
              ? format.formatDistance(distanceValue, locale: locale)
              : formatter.distance(distanceValue, sport.id),
        ),
      (
        l10n.statsDuration,
        format.formatDuration(data.totals.durationSeconds.round()),
      ),
      (
        l10n.statsCount,
        NumberFormat.decimalPattern(locale).format(data.totals.count),
      ),
      (
        l10n.statsElevation,
        format.formatElevation(data.totals.elevationMeters, locale: locale),
      ),
    ];
    final distanceChart = sport?.hasDistance ?? false;
    final maximum = data.buckets.fold<double>(
      0,
      (max, b) => math.max(
        max,
        distanceChart ? b.metrics.distanceMeters : b.metrics.durationSeconds,
      ),
    );
    return [
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final value in values)
            SizedBox(
              width: 155,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.$1,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value.$2,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      if (data.totals.count == 0)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(l10n.statsEmpty),
        ),
      const SizedBox(height: 24),
      Text(
        distanceChart ? l10n.statsDistanceTrend : l10n.statsDurationTrend,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      if (_controller.query.period == StatisticsPeriod.month)
        Text(
          l10n.statsPartialWeeks,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      for (final bucket in data.buckets)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${_bucketLabel(bucket.index, l10n)} · ${distanceChart ? formatter.distance(bucket.metrics.distanceMeters, sport!.id) : format.formatDuration(bucket.metrics.durationSeconds.round())}',
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: maximum == 0
                    ? 0
                    : (distanceChart
                              ? bucket.metrics.distanceMeters
                              : bucket.metrics.durationSeconds) /
                          maximum,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      const SizedBox(height: 24),
      Text(l10n.statsSports, style: Theme.of(context).textTheme.titleMedium),
      for (final item in data.sports)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.serverActivitySport('${item.id}')),
          subtitle: Text(
            '${item.metrics.count} · ${format.formatDuration(item.metrics.durationSeconds.round())}',
          ),
          trailing: item.hasDistance
              ? Text(formatter.distance(item.metrics.distanceMeters, item.id))
              : null,
          onTap: () => _set(sport: item, changeSport: true),
        ),
      if (sport != null)
        TextButton(
          onPressed: () => _set(changeSport: true),
          child: Text(l10n.serverActivitiesAllSports),
        ),
      const SizedBox(height: 24),
    ];
  }

  String _bucketLabel(int index, AppLocalizations l10n) =>
      switch (_controller.query.period) {
        StatisticsPeriod.week => DateFormat.EEEE(
          context.numberFormatLocale,
        ).format(DateTime(2024, 1, 1 + index)),
        StatisticsPeriod.month => l10n.statsWeekNumber(index),
        StatisticsPeriod.year => DateFormat.MMMM(
          context.numberFormatLocale,
        ).format(DateTime(2024, index)),
      };
}
