import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';
import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/utils/serial_task_queue.dart';
import 'package:endurain/features/activity/models/activity_recording_state.dart';
import 'package:endurain/features/activity/models/activity_track_point.dart';
import 'package:endurain/features/activity/models/activity_track_segment.dart';
import 'package:endurain/features/activity/models/activity_type.dart';
import 'package:endurain/features/activity/models/local_activity_record.dart';
import 'package:endurain/features/activity/repositories/local_activity_repository.dart';
import 'package:endurain/features/activity/services/activity_upload_queue.dart';
import 'package:endurain/features/activity/services/local_activity_summary_builder.dart';
import 'package:endurain/features/osmand/osmand_host_bridge.dart';

/// Explicit, save-first import. A copied file's identity survives restarts and
/// account changes; importing again never silently moves it to another account.
class OsmandRecordingImporter {
  OsmandRecordingImporter({
    required this.repository,
    required this.uploadQueue,
    this.bridge = const OsmandHostBridge(),
  });
  final LocalActivityRepository repository;
  final ActivityUploadQueue uploadQueue;
  final OsmandHostBridge bridge;
  static final _imports = SerialTaskQueue();

  Future<LocalActivityRecord> importRecording(
    OsmandRecording source, {
    required ActivityType activityType,
    required ConnectionProfile? destination,
  }) => _imports.run(() async {
    final bytes = await bridge.readCompletedRecording(source);
    // Content identity also catches renames/copies of an already imported file.
    final id = 'osmand_${sha256.convert(bytes)}';
    final existing = await repository.get(id);
    if (existing != null) return existing;
    final gpx = utf8.decode(bytes);
    final segments = _parse(gpx);
    final points = segments.expand((segment) => segment.points).toList();
    if (points.isEmpty) {
      throw const FormatException('The GPX has no timed track points.');
    }
    final createdAt = DateTime.now().toUtc();
    final fileName = await repository.writeGpx(id: id, gpx: gpx);
    final state = ActivityRecordingState(
      status: ActivityRecordingStatus.completed,
      activityType: activityType,
      startedAt: points.first.timestamp,
      endedAt: points.last.timestamp,
      segments: segments,
    );
    final record = LocalActivitySummaryBuilder()
        .build(
          state: state,
          id: id,
          gpxFileName: fileName,
          createdAt: createdAt,
        )
        .copyWith(
          // Existing queue automatically claims null destinations on sign-in.
          // Explicit local-only sentinel keeps guest imports local across logins.
          connectionOrigin: destination?.origin ?? 'osmand-local-only:',
          connectionProfileId: destination?.id ?? 'osmand-local-only',
          idempotencyKey: id,
        );
    await repository.upsert(record);
    if (destination != null) await uploadQueue.drain();
    return await repository.get(id) ?? record;
  });

  List<ActivityTrackSegment> _parse(String gpx) {
    final document = XmlDocument.parse(gpx);
    if (document.rootElement.name.local != 'gpx') {
      throw const FormatException('The saved file is not GPX.');
    }
    final segments = <ActivityTrackSegment>[];
    for (final segment in document.descendants.whereType<XmlElement>().where(
      (e) => e.name.local == 'trkseg',
    )) {
      final points = <ActivityTrackPoint>[];
      for (final point in segment.childElements.where(
        (e) => e.name.local == 'trkpt',
      )) {
        final lat = double.tryParse(point.getAttribute('lat') ?? '');
        final lon = double.tryParse(point.getAttribute('lon') ?? '');
        String? childText(String name) {
          for (final child in point.descendants.whereType<XmlElement>()) {
            if (child.name.local == name) return child.innerText;
          }
          return null;
        }

        final time = DateTime.tryParse(childText('time') ?? '');
        if (lat == null ||
            lon == null ||
            time == null ||
            !lat.isFinite ||
            !lon.isFinite ||
            lat < -90 ||
            lat > 90 ||
            lon < -180 ||
            lon > 180) {
          // Do not join across malformed/missing timestamps in the summary.
          if (points.isNotEmpty) {
            segments.add(ActivityTrackSegment(points: List.of(points)));
            points.clear();
          }
          continue;
        }
        if (points.isNotEmpty && time.isBefore(points.last.timestamp)) {
          segments.add(ActivityTrackSegment(points: List.of(points)));
          points.clear();
        }
        final elevation = double.tryParse(childText('ele') ?? '');
        points.add(
          ActivityTrackPoint(
            latitude: lat,
            longitude: lon,
            timestamp: time.toUtc(),
            elevationMeters: elevation != null && elevation.isFinite
                ? elevation
                : null,
            heartRateBpm: int.tryParse(childText('hr') ?? ''),
            cadenceRpm: int.tryParse(childText('cad') ?? ''),
            powerWatts: int.tryParse(childText('power') ?? ''),
          ),
        );
      }
      if (points.isNotEmpty) segments.add(ActivityTrackSegment(points: points));
    }
    return segments;
  }
}
