import 'dart:async';

import 'package:endurain/core/services/app_scope.dart';
import 'package:endurain/features/achievements/controllers/achievements_controller.dart';
import 'package:endurain/features/achievements/repositories/achievements_repository.dart';
import 'package:endurain/features/achievements/widgets/achievement_record_card.dart';
import 'package:endurain/features/activity/services/activity_stats_formatter_scope.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';
import 'package:endurain/shared/state/owned_controllers.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class PersonalBestsScreen extends StatefulWidget {
  const PersonalBestsScreen({super.key, this.controller});
  final AchievementsController? controller;
  @override
  State<PersonalBestsScreen> createState() => _PersonalBestsScreenState();
}

class _PersonalBestsScreenState extends State<PersonalBestsScreen>
    with OwnedControllers {
  late final AchievementsController _controller;
  @override
  void initState() {
    super.initState();
    _controller = registerController(
      widget.controller,
      () => AppScope.servicesOf(
        context,
        listen: false,
      ).createAchievementsController(),
    );
    unawaited(_controller.initialize());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final numbers = NumberFormat.decimalPattern(context.numberFormatLocale);
    return AdaptiveScaffold(
      title: l.achievementsTitle,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final scan = _controller.scanState;
          final records = _controller.records;
          return RefreshIndicator(
            onRefresh: _controller.isGuest ? () async {} : _controller.refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(
                  l.achievementsLocal,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (_controller.isLoading) const LinearProgressIndicator(),
                if (_controller.isGuest)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(l.achievementsGuest),
                  )
                else ...[
                  Text(
                    l.achievementsGpsNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      DropdownButton<int>(
                        isExpanded: true,
                        value: _controller.selectedSport ?? 0,
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(l.serverActivitiesAllSports),
                          ),
                          for (final sport in _controller.availableSports)
                            DropdownMenuItem(
                              value: sport,
                              child: Text(l.serverActivitySport('$sport')),
                            ),
                        ],
                        onChanged: (value) =>
                            _controller.setSport(value == 0 ? null : value),
                      ),
                      DropdownButton<int>(
                        isExpanded: true,
                        value: _controller.selectedYear ?? 0,
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(l.achievementsAllTime),
                          ),
                          for (final year in _controller.availableYears)
                            DropdownMenuItem(value: year, child: Text('$year')),
                        ],
                        onChanged: (value) =>
                            _controller.setYear(value == 0 ? null : value),
                      ),
                    ],
                  ),
                  if (scan == null)
                    Text(l.achievementsNotAnalysed)
                  else ...[
                    Text(
                      scan.status == AchievementScanStatus.complete &&
                              !_controller.isScanning &&
                              !_controller.snapshot!.outdatedCalculation
                          ? l.achievementsComplete
                          : l.achievementsPartial,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      l.achievementsProgress(
                        numbers.format(scan.processedCount),
                        numbers.format(scan.totalCount),
                      ),
                    ),
                    if (_controller.isScanning)
                      LinearProgressIndicator(
                        value: scan.totalCount > 0
                            ? (scan.processedCount / scan.totalCount).clamp(
                                0,
                                1,
                              )
                            : null,
                      ),
                    Text(
                      l.achievementsCoverage(
                        numbers.format(scan.usableTrackCount),
                        numbers.format(scan.unavailableTrackCount),
                        numbers.format(scan.failures.length),
                      ),
                    ),
                    if (scan.lastSuccessfulAt case final date?)
                      Text(
                        l.achievementsLastAnalysis(
                          DateFormat.yMMMd(context.numberFormatLocale)
                              .add_jm()
                              .format(date.toLocal()),
                        ),
                      ),
                    if (scan.firstDayOfWeek == null)
                      Text(l.achievementsWeeklyUnavailable),
                    if (scan.skipped.isNotEmpty)
                      ExpansionTile(
                        title: Text(
                          l.achievementsSkipped('${scan.skipped.length}'),
                        ),
                        children: [
                          for (final entry in scan.skipped.entries)
                            ListTile(
                              title: Text(
                                l.achievementsActivity('${entry.key}'),
                              ),
                              subtitle: Text(
                                entry.value
                                    .map((reason) => _reason(reason, l))
                                    .toSet()
                                    .join(' · '),
                              ),
                            ),
                        ],
                      ),
                  ],
                  if (_controller.snapshot?.outdatedCalculation ?? false)
                    Text(l.achievementsOutdated),
                  if (_controller.error != null ||
                      scan?.status == AchievementScanStatus.failed ||
                      (scan?.failures.isNotEmpty ?? false))
                    Text(
                      l.achievementsFailed,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (_controller.isScanning)
                        TextButton(
                          onPressed: _controller.cancel,
                          child: Text(l.cancel),
                        )
                      else ...[
                        FilledButton(
                          onPressed: _controller.refresh,
                          child: Text(
                            scan == null
                                ? l.achievementsAnalyse
                                : (_controller.error != null ||
                                          scan.status ==
                                              AchievementScanStatus.failed ||
                                          scan.failures.isNotEmpty
                                      ? l.serverActivitiesRetry
                                      : l.activityHistoryRefresh),
                          ),
                        ),
                        if (scan != null)
                          TextButton(
                            onPressed: _controller.rebuild,
                            child: Text(l.achievementsRebuild),
                          ),
                      ],
                    ],
                  ),
                  if (scan != null)
                    Text(
                      l.achievementsRebuildNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 16),
                  if (records.isEmpty && scan != null && !_controller.isLoading)
                    Text(
                      scan.status == AchievementScanStatus.complete &&
                              scan.totalCount == 0
                          ? l.achievementsNoActivities
                          : l.achievementsEmpty,
                    ),
                  for (final record in records)
                    AchievementRecordCard(record: record),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _reason(String reason, AppLocalizations l) => switch (reason) {
    'gpsUnavailable' || 'gpsNoContinuousTravel' => l.achievementsGpsUnavailable,
    'invalidGpsPoint' ||
    'unorderedGpsTime' ||
    'gpsGap' ||
    'gpsJump' => l.achievementsGpsQuality,
    'sportHasNoDistanceEfforts' => l.achievementsUnsupportedSport,
    'missingAbsoluteDate' => l.achievementsDateExcluded,
    _ => l.achievementsOtherExclusion,
  };
}
