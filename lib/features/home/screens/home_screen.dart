import 'dart:async';

import 'package:endurain/features/activity/models/local_activity_record.dart';
import 'package:endurain/features/activity/screens/activity_details_screen.dart';
import 'package:endurain/features/activity/services/activity_stats_formatter_scope.dart';
import 'package:endurain/features/activity/widgets/activity_type_label.dart';
import 'package:endurain/features/home/controllers/home_controller.dart';
import 'package:endurain/features/home/widgets/home_goal_card.dart';
import 'package:endurain/features/home/widgets/home_week_card.dart';
import 'package:endurain/features/home/widgets/home_activity_card.dart';
import 'package:endurain/features/server_activities/screens/server_activity_detail_screen.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';
import 'package:endurain/shared/widgets/cache_last_updated_chip.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// The action occupies its own layout space, independent of scroll position or
/// the availability of any of the three dashboard data sources.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.onRecordActivity,
    required this.onOpenActivities,
    this.hasActiveRecording = false,
    this.isRecordingPaused = false,
  });
  final HomeController controller;
  final VoidCallback onRecordActivity;
  final VoidCallback onOpenActivities;
  final bool hasActiveRecording;
  final bool isRecordingPaused;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(widget.controller.refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.controller.refreshIfStale());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveScaffold(
      title: 'endurain',
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                final controller = widget.controller;
                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView(
                    key: const Key('home-scroll'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      Text(
                        l10n.homeGreeting,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      HomeWeekCard(
                        statistics: controller.statistics,
                        anchor: controller.weekAnchor,
                        loading: controller.statisticsLoading,
                        error: controller.statisticsError != null,
                      ),
                      const SizedBox(height: 24),
                      _section(
                        context,
                        l10n.homeGoals,
                        l10n.homeAllGoals,
                        controller.goals.isEmpty
                            ? null
                            : () => adaptivePush<void>(
                                context,
                                (_) => _AllGoalsScreen(controller: controller),
                              ),
                      ),
                      if (controller.goalsLoading) const AdaptiveProgressBar(),
                      if (controller.goalsError != null) _error(context),
                      if (controller.goalsCacheFetchedAt != null)
                        CacheLastUpdatedChip(
                          fetchedAt: controller.goalsCacheFetchedAt!,
                        ),
                      if (controller.visibleGoals.isEmpty &&
                          !controller.goalsLoading)
                        _notice(
                          context,
                          controller.isGuest
                              ? l10n.homeGuestGoals
                              : l10n.homeNoGoals,
                        ),
                      for (final goal in controller.visibleGoals)
                        HomeGoalCard(goal: goal),
                      const SizedBox(height: 24),
                      _section(
                        context,
                        l10n.homeRecent,
                        l10n.homeAllActivities,
                        widget.onOpenActivities,
                      ),
                      if (controller.activitiesLoading)
                        const AdaptiveProgressBar(),
                      if (controller.activitiesError != null) _error(context),
                      if (controller.activities.isEmpty &&
                          controller.localActivities.isEmpty &&
                          !controller.activitiesLoading)
                        _notice(context, l10n.homeNoActivities),
                      for (final activity in controller.activities)
                        HomeActivityCard(
                          key: ValueKey(activity),
                          activity: activity,
                          loadRoute: () => controller.loadRoute(activity.id),
                          onTap: () => adaptivePush<void>(
                            context,
                            (_) => ServerActivityDetailScreen(
                              activityId: activity.id,
                            ),
                          ),
                        ),
                      for (final activity in controller.localActivities.take(3))
                        _localActivity(context, activity),
                      if (controller.hasPendingUploads)
                        _notice(context, l10n.homePendingUploads),
                    ],
                  ),
                );
              },
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.hasActiveRecording)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        widget.isRecordingPaused
                            ? l10n.homeRecordingPaused
                            : l10n.homeRecordingActive,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  AdaptiveButton(
                    key: const Key('home-record-action'),
                    label: widget.hasActiveRecording
                        ? l10n.homeReturnToRecording
                        : l10n.homeRecordActivity,
                    icon: Icon(
                      widget.hasActiveRecording
                          ? Icons.radio_button_checked
                          : Icons.add_circle_outline,
                    ),
                    onPressed: widget.onRecordActivity,
                    expand: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _localActivity(BuildContext context, LocalActivityRecord activity) {
    final formatter = context.statsFormatter;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.fitness_center),
        title: Text(activity.activityType.localizedLabel(l10n)),
        subtitle: Text(
          '${DateFormat.yMMMd(context.numberFormatLocale).format(activity.startedAt.toLocal())}\n${formatter.formatDistance(activity.distanceMeters, locale: context.numberFormatLocale)} · ${formatter.formatDuration(activity.elapsedDurationSeconds)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => adaptivePush<void>(
          context,
          (_) => ActivityDetailsScreen(recordId: activity.id),
        ),
      ),
    );
  }
}

Widget _section(
  BuildContext context,
  String title,
  String action,
  VoidCallback? onTap,
) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      if (onTap != null)
        AdaptiveButton(
          label: action,
          onPressed: onTap,
          variant: AdaptiveButtonVariant.secondary,
        ),
    ],
  ),
);
Widget _notice(BuildContext context, String text) => Padding(
  padding: const EdgeInsets.all(16),
  child: Text(
    text,
    style: Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
  ),
);
Widget _error(BuildContext context) =>
    _notice(context, AppLocalizations.of(context)!.homeLoadFailed);

class _AllGoalsScreen extends StatelessWidget {
  const _AllGoalsScreen({required this.controller});
  final HomeController controller;
  @override
  Widget build(BuildContext context) => AdaptiveScaffold(
    title: AppLocalizations.of(context)!.homeAllGoals,
    body: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.goalsLoading) const AdaptiveProgressBar(),
            if (controller.goalsError != null) _error(context),
            if (controller.goalsCacheFetchedAt != null)
              CacheLastUpdatedChip(fetchedAt: controller.goalsCacheFetchedAt!),
            if (controller.goals.isEmpty)
              _notice(
                context,
                controller.isGuest
                    ? AppLocalizations.of(context)!.homeGuestGoals
                    : AppLocalizations.of(context)!.homeNoGoals,
              ),
            for (final goal in controller.goals) HomeGoalCard(goal: goal),
          ],
        ),
      ),
    ),
  );
}
