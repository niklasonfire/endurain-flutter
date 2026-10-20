import 'package:flutter/material.dart';
import 'package:endurain/core/services/app_scope.dart';
import 'package:endurain/features/activity/models/activity_type.dart';
import 'package:endurain/features/activity/models/local_activity_record.dart';
import 'package:endurain/features/osmand/osmand_host_bridge.dart';
import 'package:endurain/features/osmand/osmand_recording_importer.dart';

/// POC entry point: users explicitly choose a saved track and its destination.
class OsmandRecordingsScreen extends StatefulWidget {
  const OsmandRecordingsScreen({super.key});
  @override
  State<OsmandRecordingsScreen> createState() => _OsmandRecordingsScreenState();
}

class _OsmandRecordingsScreenState extends State<OsmandRecordingsScreen> {
  static const _bridge = OsmandHostBridge();
  late Future<List<OsmandRecording>> _recordings;
  ActivityType _type = ActivityType.other;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _recordings = _bridge.listCompletedRecordings();
  }

  Future<void> _import(OsmandRecording recording) async {
    final services = AppScope.servicesOf(context, listen: false);
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final destination = await services.authSession.getConnectionProfile();
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('OsmAnd-Aufzeichnung importieren?'),
          content: Text(
            destination == null
                ? 'Lokal speichern. Diese Kopie wird auch nach einer späteren Anmeldung nicht automatisch hochgeladen.'
                : 'Lokal speichern und zum aktuell angemeldeten Konto auf ${destination.origin} hochladen. Bereits importierte Dateien behalten ihr ursprüngliches Zielkonto.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Importieren'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      final current = await services.authSession.getConnectionProfile();
      if (current?.id != destination?.id ||
          current?.origin != destination?.origin) {
        throw StateError(
          'Das Konto wurde gewechselt. Bitte erneut importieren.',
        );
      }
      final record =
          await OsmandRecordingImporter(
            repository: services.localActivities,
            uploadQueue: services.activityUploadQueue,
          ).importRecording(
            recording,
            activityType: _type,
            destination: destination,
          );
      if (!mounted) return;
      final sameDestination =
          record.connectionProfileId == destination?.id &&
          record.connectionOrigin == destination?.origin;
      setState(
        () =>
            _message = record.uploadStatus == LocalActivityUploadStatus.uploaded
            ? 'Bereits erfolgreich hochgeladen.'
            : destination == null || !sameDestination
            ? 'Lokal vorhanden. Die Datei bleibt ihrem bisherigen lokalen Speicher oder Konto zugeordnet.'
            : 'Lokal gespeichert. Uploadstatus: ${record.uploadStatus.name}. Offline oder fehlgeschlagene Uploads bleiben in der bestehenden Warteschlange.',
      );
    } catch (error) {
      if (mounted) setState(() => _message = 'Import fehlgeschlagen: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('OsmAnd-Aufzeichnungen'),
      actions: [
        IconButton(
          tooltip: 'Aktualisieren',
          onPressed: _busy
              ? null
              : () => setState(
                  () => _recordings = _bridge.listCompletedRecordings(),
                ),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Zuerst die Aufnahme in OsmAnd beenden und als GPX speichern. Originaldateien bleiben erhalten. Zum Endurain-Frontend mit Android Zurück wechseln.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<ActivityType>(
            value: _type,
            isExpanded: true,
            onChanged: _busy ? null : (value) => setState(() => _type = value!),
            items: ActivityType.values
                .map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.name)),
                )
                .toList(),
          ),
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_message != null)
          Padding(padding: const EdgeInsets.all(16), child: Text(_message!)),
        Expanded(
          child: FutureBuilder<List<OsmandRecording>>(
            future: _recordings,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Aufzeichnungen konnten nicht gelesen werden: ${snapshot.error}',
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final recordings = snapshot.data!;
              if (recordings.isEmpty) {
                return const Center(
                  child: Text('Noch keine gespeicherten GPX-Aufzeichnungen.'),
                );
              }
              return ListView.builder(
                itemCount: recordings.length,
                itemBuilder: (context, index) {
                  final recording = recordings[index];
                  return ListTile(
                    title: Text(recording.name),
                    subtitle: Text(
                      '${recording.modifiedAt.toLocal()} · ${recording.size} Bytes',
                    ),
                    trailing: const Icon(Icons.file_download_outlined),
                    onTap: _busy ? null : () => _import(recording),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}
