import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:endurain/core/services/app_scope.dart';
import 'package:endurain/core/utils/error_localizations.dart';
import 'package:endurain/features/updates/update_controller.dart';
import 'package:endurain/features/updates/update_release.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key, this.controller});
  final UpdateController? controller;

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen>
    with WidgetsBindingObserver {
  late final UpdateController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller =
        widget.controller ??
        AppScope.servicesOf(context, listen: false).createUpdateController();
    unawaited(_controller.load());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_controller.onResume());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveScaffold(
      title: l10n.updatesTitle,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final installed = _controller.installed;
          final release = _controller.release;
          final status = _controller.status;
          final busy =
              status == UpdateStatus.loading ||
              status == UpdateStatus.checking ||
              status == UpdateStatus.downloading;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (installed != null)
                Text(
                  l10n.updatesInstalled(
                    '${installed.versionName}+${installed.versionCode}',
                    switch (const String.fromEnvironment(
                      'ENDURAIN_UPDATE_CHANNEL',
                      defaultValue: 'local',
                    )) {
                      'stable' => 'Stable',
                      'nightly' => 'Nightly',
                      'check' => l10n.updatesCheckChannel,
                      _ => l10n.updatesLocalChannel,
                    },
                  ),
                ),
              const SizedBox(height: 16),
              AdaptiveListSection(
                children: [
                  for (final channel in UpdateChannel.values)
                    AdaptiveListTile(
                      title: channel == UpdateChannel.stable
                          ? 'Stable'
                          : 'Nightly',
                      subtitle: channel == UpdateChannel.nightly
                          ? l10n.updatesNightlyDescription
                          : null,
                      trailing: _controller.channel == channel
                          ? const Icon(Icons.check)
                          : null,
                      onTap: status == UpdateStatus.loading
                          ? null
                          : () => _controller.selectChannel(channel),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AdaptiveButton(
                onPressed: busy || installed?.supported != true
                    ? null
                    : _controller.check,
                label: l10n.updatesCheck,
              ),
              if (_controller.lastChecked != null)
                Text(
                  l10n.updatesLastChecked(
                    '${MaterialLocalizations.of(context).formatFullDate(_controller.lastChecked!.toLocal())} ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_controller.lastChecked!.toLocal()))}',
                  ),
                ),
              const SizedBox(height: 16),
              if (status == UpdateStatus.loading ||
                  status == UpdateStatus.checking)
                const Center(child: AdaptiveLoadingIndicator()),
              if (installed?.supported == false) Text(l10n.updatesUnsupported),
              if (status == UpdateStatus.current) Text(l10n.updatesCurrent),
              if (status == UpdateStatus.waitingStable)
                Text(l10n.updatesWaitingStable),
              if (_controller.error != null)
                Text(localizedErrorMessage(_controller.error!, l10n)),
              if (release != null &&
                  status != UpdateStatus.current &&
                  status != UpdateStatus.waitingStable) ...[
                Text(
                  '${release.versionName}+${release.versionCode}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${MaterialLocalizations.of(context).formatFullDate(release.builtAt.toLocal())} • ${(release.size / 1048576).toStringAsFixed(1)} MB',
                ),
                const SizedBox(height: 8),
                Text(release.notes),
                const SizedBox(height: 16),
                if (status == UpdateStatus.downloading) ...[
                  LinearProgressIndicator(value: _controller.progress),
                  Text(
                    '${((_controller.progress ?? 0) * 100).toStringAsFixed(0)}%',
                  ),
                  AdaptiveButton(
                    onPressed: _controller.cancel,
                    label: l10n.cancel,
                  ),
                ] else if ({
                  UpdateStatus.ready,
                  UpdateStatus.permissionRequired,
                  UpdateStatus.installerOpened,
                }.contains(status)) ...[
                  if (status == UpdateStatus.permissionRequired)
                    Text(l10n.updatesPermission),
                  if (status == UpdateStatus.installerOpened)
                    Text(l10n.updatesInstallerOpened),
                  if (_controller.installationBlocked)
                    Text(l10n.updatesRecordingActive),
                  AdaptiveButton(
                    onPressed: _controller.installationBlocked
                        ? null
                        : _controller.install,
                    label: l10n.updatesInstall,
                  ),
                ] else if (release.versionCode > (installed?.versionCode ?? 0))
                  AdaptiveButton(
                    onPressed: busy ? null : _controller.download,
                    label: l10n.updatesDownload,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
