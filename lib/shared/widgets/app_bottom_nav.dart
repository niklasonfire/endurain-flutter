import 'dart:async';

import 'package:endurain/core/services/app_scope.dart';
import 'package:endurain/features/home/controllers/home_controller.dart';
import 'package:endurain/features/home/screens/home_screen.dart';
import 'package:endurain/features/activity/controllers/activity_recording_controller.dart';
import 'package:endurain/features/activity/models/activity_recording_state.dart';
import 'package:endurain/features/activity/models/activity_upload_state.dart';
import 'package:endurain/features/statistics/screens/statistics_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:endurain/features/server_activities/screens/server_activities_screen.dart';
import 'package:endurain/features/server_activities/screens/server_activity_detail_screen.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:endurain/core/navigation/app_routes.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:endurain/features/map/screens/map_screen.dart';
import 'package:endurain/features/settings/screens/settings_screen.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({
    super.key,
    this.onLogout,
    this.isGuest = false,
    this.onSignIn,
  });

  final VoidCallback? onLogout;

  /// Whether the app is running in local-only guest mode (no server session).
  final bool isGuest;

  /// Invoked from Settings when a guest wants to connect a server / sign in.
  final VoidCallback? onSignIn;

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  late final HomeController _home;
  late final ActivityRecordingController _recording;
  late final StreamSubscription<void> _uploadSubscription;
  ActivityUploadStatus _lastUploadStatus = ActivityUploadStatus.idle;
  int _selectedIndex = 0;
  bool _recordingScreenOpen = false;

  @override
  void initState() {
    super.initState();
    final services = AppScope.servicesOf(context, listen: false);
    _home = services.createHomeController();
    _recording = services.activityRecordingController;
    _lastUploadStatus = _recording.uploadStatus;
    _recording.addListener(_recordingChanged);
    _uploadSubscription = services.activityUploadQueue.onDrainCompleted.listen(
      (_) => unawaited(_home.refresh()),
    );
  }

  void _recordingChanged() {
    final status = _recording.uploadStatus;
    if (_lastUploadStatus != status &&
        (status == ActivityUploadStatus.uploaded ||
            status == ActivityUploadStatus.cleanupFailed)) {
      unawaited(_home.refresh());
    }
    _lastUploadStatus = status;
    if (mounted) setState(() {});
  }

  Future<void> _openRecording(BuildContext tabContext) async {
    if (_recordingScreenOpen) return;
    _recordingScreenOpen = true;
    try {
      await adaptivePush<void>(tabContext, (_) => const MapScreen());
    } finally {
      _recordingScreenOpen = false;
      if (mounted) unawaited(_home.refresh());
    }
  }

  @override
  void dispose() {
    _recording.removeListener(_recordingChanged);
    unawaited(_uploadSubscription.cancel());
    _home.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdaptiveBottomNavigation(
      selectedIndex: _selectedIndex,
      onIndexChanged: (index) => setState(() => _selectedIndex = index),
      tabs: [
        AdaptiveTab(
          routeName: AppRoutes.home,
          label: l10n.homeTab,
          materialIcon: Icons.home_rounded,
          cupertinoIcon: CupertinoIcons.house_fill,
          builder: (context) => HomeScreen(
            controller: _home,
            onRecordActivity: () => unawaited(_openRecording(context)),
            onOpenActivities: () => setState(() => _selectedIndex = 1),
            hasActiveRecording:
                _recording.state.isActive ||
                _recording.state.canRecover ||
                _recording.state.status == ActivityRecordingStatus.completed ||
                _recording.state.status == ActivityRecordingStatus.stopping,
            isRecordingPaused:
                _recording.state.status == ActivityRecordingStatus.paused,
          ),
        ),
        AdaptiveTab(
          routeName: AppRoutes.activities,
          label: l10n.activitiesTab,
          materialIcon: Icons.directions_run,
          cupertinoIcon: CupertinoIcons.list_bullet,
          builder: (context) => ServerActivitiesScreen(
            onSignIn: widget.onSignIn,
            onOpenActivity: (activity) => adaptivePush<void>(
              context,
              (_) => ServerActivityDetailScreen(activityId: activity.id),
            ),
          ),
        ),
        AdaptiveTab(
          routeName: AppRoutes.statistics,
          label: l10n.statsTab,
          materialIcon: Icons.bar_chart,
          cupertinoIcon: CupertinoIcons.chart_bar,
          builder: (context) => StatisticsScreen(onSignIn: widget.onSignIn),
        ),
        AdaptiveTab(
          routeName: AppRoutes.settings,
          label: l10n.settingsTab,
          materialIcon: Icons.settings,
          cupertinoIcon: CupertinoIcons.settings,
          builder: (context) => SettingsScreen(
            onLogout: widget.onLogout,
            isGuest: widget.isGuest,
            onSignIn: widget.onSignIn,
          ),
        ),
      ],
    );
  }
}
