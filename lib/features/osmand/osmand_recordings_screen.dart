import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:endurain/core/services/app_scope.dart';
import 'package:endurain/features/activity/models/activity_type.dart';
import 'package:endurain/features/activity/widgets/activity_type_label.dart';
import 'package:endurain/features/osmand/osmand_host_bridge.dart';
import 'package:endurain/features/osmand/osmand_recordings_controller.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:endurain/shared/state/owned_controllers.dart';

class OsmandRecordingsScreen extends StatefulWidget {
  const OsmandRecordingsScreen({super.key, this.controller});
  final OsmandRecordingsController? controller;
  @override
  State<OsmandRecordingsScreen> createState() => _OsmandRecordingsScreenState();
}

class _OsmandRecordingsScreenState extends State<OsmandRecordingsScreen>
    with OwnedControllers {
  late final OsmandRecordingsController _controller;
  @override
  void initState() {
    super.initState();
    _controller = registerController(
      widget.controller,
      () => AppScope.servicesOf(
        context,
        listen: false,
      ).createOsmandRecordingsController(),
    );
    unawaited(_controller.refresh());
  }

  Future<void> _confirmImport(OsmandRecording recording) async {
    final destination = await _controller.prepareImport();
    if (!mounted || destination == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.osmandImportTitle),
        content: Text(
          destination.profile == null
              ? l10n.osmandImportLocalConfirmation
              : l10n.osmandImportAccountConfirmation(
                  destination.profile!.origin,
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.osmandImportAction),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) {
      _controller.cancelImport();
      return;
    }
    await _controller.importRecording(recording, destination);
  }

  String _message(AppLocalizations l10n, OsmandImportMessage message) =>
      switch (message) {
        OsmandImportMessage.previouslyImported => l10n.osmandPreviouslyImported,
        OsmandImportMessage.uploaded => l10n.activityUploaded,
        OsmandImportMessage.local => l10n.osmandImportLocalResult,
        OsmandImportMessage.queued => l10n.osmandImportQueuedResult,
        OsmandImportMessage.failed => l10n.osmandImportUploadFailed,
        OsmandImportMessage.accountChanged => l10n.osmandImportAccountChanged,
        OsmandImportMessage.importFailed => l10n.osmandImportFailed,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.osmandRecordingsTitle),
          actions: [
            IconButton(
              tooltip: l10n.osmandRefresh,
              onPressed: _controller.busy || _controller.loading
                  ? null
                  : _controller.refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.osmandRecordingsInstructions),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<ActivityType>(
                value: _controller.activityType,
                isExpanded: true,
                onChanged: _controller.busy
                    ? null
                    : (value) {
                        if (value != null) _controller.selectType(value);
                      },
                items: ActivityType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.localizedLabel(l10n)),
                      ),
                    )
                    .toList(),
              ),
            ),
            if (_controller.busy || _controller.loading)
              const LinearProgressIndicator(),
            if (_controller.message != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_message(l10n, _controller.message!)),
              ),
            Expanded(
              child: _controller.loadFailed
                  ? Center(child: Text(l10n.osmandRecordingsLoadFailed))
                  : _controller.recordings.isEmpty && !_controller.loading
                  ? Center(child: Text(l10n.osmandRecordingsEmpty))
                  : ListView.builder(
                      itemCount: _controller.recordings.length,
                      itemBuilder: (context, index) {
                        final recording = _controller.recordings[index];
                        final date = DateFormat.yMd(l10n.localeName)
                            .add_Hm()
                            .format(recording.modifiedAt.toLocal());
                        return ListTile(
                          title: Text(recording.name),
                          subtitle: Text(date),
                          trailing: const Icon(Icons.file_download_outlined),
                          onTap: _controller.busy
                              ? null
                              : () => _confirmImport(recording),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
