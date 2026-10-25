import 'package:endurain/features/server_activities/widgets/server_activity_charts.dart';

import 'dart:async';

import 'package:endurain/core/constants/map_constants.dart';
import 'package:endurain/core/services/app_scope.dart';
import 'package:endurain/features/activity/services/activity_stats_formatter_scope.dart';
import 'package:endurain/features/server_activities/controllers/server_activity_detail_controller.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/services/server_activity_formatter.dart';
import 'package:endurain/features/server_activities/widgets/server_activity_list_item.dart';
import 'package:endurain/features/server_activities/widgets/server_activity_route_map.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';
import 'package:endurain/shared/state/owned_controllers.dart';
import 'package:endurain/shared/widgets/cache_last_updated_chip.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class ServerActivityDetailScreen extends StatefulWidget {
  const ServerActivityDetailScreen({
    super.key,
    required this.activityId,
    this.controller,
    this.tileServerUrlProvider,
  });
  final int activityId;
  final ServerActivityDetailController? controller;
  final Future<String> Function()? tileServerUrlProvider;

  @override
  State<ServerActivityDetailScreen> createState() =>
      _ServerActivityDetailScreenState();
}

class _ServerActivityDetailScreenState extends State<ServerActivityDetailScreen>
    with OwnedControllers {
  late final ServerActivityDetailController _controller;
  String? _tiles;
  DateTime? _selectedTime;

  @override
  void initState() {
    super.initState();
    _controller = registerController(widget.controller, () {
      final services = AppScope.servicesOf(context, listen: false);
      return ServerActivityDetailController(
        activityId: widget.activityId,
        repository: services.serverActivities,
        connection: services.authSession.connectionChanges,
      );
    });
    unawaited(_controller.load());
    unawaited(_loadTiles());
  }

  Future<void> _loadTiles() async {
    try {
      final provider = widget.tileServerUrlProvider;
      final services = AppScope.maybeServicesOf(context, listen: false);
      final tiles = provider != null
          ? await provider()
          : await services?.createMapSettingsRepository().getTileServerUrl() ??
                MapConstants.defaultTileServerUrl;
      if (mounted && !_controller.isAccountChanged) {
        setState(() => _tiles = tiles);
      }
    } catch (_) {
      if (mounted && !_controller.isAccountChanged) {
        setState(() => _tiles = MapConstants.defaultTileServerUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveScaffold(
      title: l10n.activityHistoryDetailsTitle,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isAccountChanged) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.serverActivityAccountChanged,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (_controller.activity == null) {
            if (_controller.isLoading) {
              return const Center(child: AdaptiveLoadingIndicator());
            }
            return Center(
              child: _retry(l10n.serverActivityDetailFailed, _controller.load),
            );
          }
          return RefreshIndicator(
            onRefresh: _controller.load,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.list(
                    children: [
                      if (_controller.isLoading)
                        const LinearProgressIndicator(),
                      if (_controller.error != null)
                        _retry(
                          l10n.serverActivityDetailFailed,
                          _controller.load,
                        ),
                      _header(_controller.activity!, l10n),
                      const SizedBox(height: 16),
                      _metrics(_controller.activity!, l10n),
                      const SizedBox(height: 20),
                      Text(
                        l10n.serverActivityRoute,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_controller.isRouteLoading)
                        const Center(child: AdaptiveLoadingIndicator())
                      else if (_controller.routeError != null)
                        _retry(
                          l10n.serverActivityRouteFailed,
                          _controller.loadRoute,
                        )
                      else if (_controller.route.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            l10n.serverActivityNoRoute,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else if (_tiles == null)
                        const Center(child: AdaptiveLoadingIndicator()),
                    ],
                  ),
                ),
                if (!_controller.isRouteLoading &&
                    _controller.routeError == null &&
                    _controller.route.isNotEmpty &&
                    _tiles != null)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _RouteHeader(
                      child: ServerActivityRouteMap(
                        route: _controller.route,
                        tileServerUrl: _tiles!,
                        startLabel: l10n.activityHistoryStartedAt,
                        finishLabel: l10n.activityHistoryEndedAt,
                        selectedTime: _selectedTime,
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.list(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        l10n.chartTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_controller.graphCacheFetchedAt != null) ...[
                        const SizedBox(height: 4),
                        CacheLastUpdatedChip(
                          fetchedAt: _controller.graphCacheFetchedAt!,
                        ),
                      ],
                      if (_controller.isGraphLoading)
                        const Center(child: AdaptiveLoadingIndicator())
                      else if (_controller.graphError != null)
                        _retry(l10n.chartLoadFailed, _controller.loadGraphs)
                      else
                        ServerActivityCharts(
                          graphs: _controller.graphs,
                          activityType: _controller.activity!.activityType,
                          selectedTime: _selectedTime,
                          onSelected: (time) =>
                              setState(() => _selectedTime = time),
                        ),
                      const SizedBox(height: 20),
                      if (_controller.isLapLoading)
                        const Center(child: AdaptiveLoadingIndicator())
                      else if (_controller.lapError != null)
                        _retry(l10n.chartLapsFailed, _controller.loadLaps)
                      else ...[
                        if (_controller.lapCacheFetchedAt != null) ...[
                          CacheLastUpdatedChip(
                            fetchedAt: _controller.lapCacheFetchedAt!,
                          ),
                          const SizedBox(height: 8),
                        ],
                        ServerActivityLaps(
                          laps: _controller.laps,
                          activityType: _controller.activity!.activityType,
                        ),
                      ],
                      if (_controller.activity!.description
                              ?.trim()
                              .isNotEmpty ??
                          false) ...[
                        const SizedBox(height: 20),
                        Text(
                          l10n.serverActivityDescription,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(_controller.activity!.description!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(ServerActivity activity, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final locale = context.numberFormatLocale;
    final sport = l10n.serverActivitySport('${activity.activityType}');
    final place = [
      activity.city ?? activity.town,
      activity.country,
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              ServerActivityListItem.sportIcon(activity.activityType),
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(sport, style: theme.textTheme.labelLarge)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          activity.name.isEmpty ? sport : activity.name,
          style: theme.textTheme.headlineSmall,
        ),
        if (activity.displayStartTime != null || activity.startTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              activity.displayStartTime?.format(
                    DateFormat.yMMMd(locale).add_jm(),
                  ) ??
                  DateFormat.yMMMd(locale)
                      .add_jm()
                      .format(activity.startTime!.toLocal()),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (place.isNotEmpty)
          Text(
            place,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _metrics(ServerActivity activity, AppLocalizations l10n) {
    final stats = context.statsFormatter;
    final locale = context.numberFormatLocale;
    final formatter = ServerActivityFormatter(
      stats: stats,
      l10n: l10n,
      locale: locale,
    );
    final distanceBased = ServerActivityFormatter.isDistanceBased(
      activity.activityType,
    );
    final duration = activity.elapsedSeconds ?? activity.timerSeconds;
    final entries = <(String, String)>[
      if (distanceBased)
        (
          l10n.activityStatDistance,
          activity.distanceMeters == null
              ? '–'
              : formatter.distance(
                  activity.distanceMeters!,
                  activity.activityType,
                ),
        ),
      (
        l10n.activityStatDuration,
        duration == null ? '–' : stats.formatDuration(duration.floor()),
      ),
      if (distanceBased)
        (
          ServerActivityFormatter.usesPace(activity.activityType)
              ? l10n.activityStatPace
              : l10n.activityStatSpeed,
          formatter.activityTempo(activity) ?? '–',
        ),
      if (distanceBased && activity.elevationGainMeters != null)
        (
          l10n.activityStatElevationGain,
          stats.formatElevation(activity.elevationGainMeters, locale: locale),
        ),
      if (activity.averageHeartRate != null)
        (
          l10n.activityStatAvgHeartRate,
          stats.formatHeartRate(activity.averageHeartRate!.round()),
        ),
      if (activity.averagePower != null)
        (
          l10n.activityStatAvgPower,
          stats.formatPower(activity.averagePower!.round()),
        ),
      if (activity.calories != null)
        (
          l10n.serverActivityCalories,
          '${NumberFormat.decimalPattern(locale).format(activity.calories!.round())} kcal',
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in entries)
              SizedBox(
                width: width,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.$1,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.$2,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _retry(String message, VoidCallback retry) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        TextButton(
          onPressed: retry,
          child: Text(AppLocalizations.of(context)!.serverActivitiesRetry),
        ),
      ],
    ),
  );
}

class _RouteHeader extends SliverPersistentHeaderDelegate {
  _RouteHeader({required this.child});
  final Widget child;
  @override
  double get minExtent => 220;
  @override
  double get maxExtent => 220;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: child,
    ),
  );
  @override
  bool shouldRebuild(_RouteHeader oldDelegate) => child != oldDelegate.child;
}
