import 'dart:async';

import 'package:endurain/core/constants/ui_constants.dart';
import 'package:endurain/core/services/app_scope.dart';
import 'package:endurain/core/utils/error_localizations.dart';
import 'package:endurain/features/updates/controllers/update_controller.dart';
import 'package:endurain/features/updates/models/update_release.dart';
import 'package:endurain/features/updates/models/update_status.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';
import 'package:endurain/shared/state/owned_controllers.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key, this.controller});
  final UpdateController? controller;

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen>
    with OwnedControllers, WidgetsBindingObserver {
  late final UpdateController _controller;
  static const _bytesPerMegabyte = 1024 * 1024;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = registerController(
      widget.controller,
      () =>
          AppScope.servicesOf(context, listen: false).createUpdateController(),
    );
    unawaited(_controller.load());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_controller.onResume());
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
            padding: const EdgeInsets.all(UIConstants.paddingStandard),
            children: [
              if (installed != null)
                Text(
                  l10n.updatesInstalled(
                    '${installed.versionName}+${installed.versionCode}',
                    switch (_controller.installedChannel) {
                      'stable' => l10n.updatesStableChannel,
                      'nightly' => l10n.updatesNightlyChannel,
                      'check' => l10n.updatesCheckChannel,
                      _ => l10n.updatesLocalChannel,
                    },
                  ),
                ),
              const SizedBox(height: UIConstants.paddingStandard),
              AdaptiveListSection(
                children: [
                  for (final channel in UpdateChannel.values)
                    AdaptiveListTile(
                      title: channel == UpdateChannel.stable
                          ? l10n.updatesStableChannel
                          : l10n.updatesNightlyChannel,
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
              const SizedBox(height: UIConstants.paddingStandard),
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
              const SizedBox(height: UIConstants.paddingStandard),
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
                  '${MaterialLocalizations.of(context).formatFullDate(release.builtAt.toLocal())} • ${l10n.updatesDownloadSize(NumberFormat('0.0', l10n.localeName).format(release.size / _bytesPerMegabyte))}',
                ),
                const SizedBox(height: UIConstants.paddingSmall),
                Text(release.notes),
                const SizedBox(height: UIConstants.paddingStandard),
                if (status == UpdateStatus.downloading) ...[
                  LinearProgressIndicator(value: _controller.progress),
                  Text(
                    NumberFormat.percentPattern(l10n.localeName)
                        .format(_controller.progress ?? 0),
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
