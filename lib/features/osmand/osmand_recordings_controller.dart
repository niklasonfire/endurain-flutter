import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/features/activity/models/activity_type.dart';
import 'package:endurain/features/activity/models/local_activity_record.dart';
import 'package:endurain/features/osmand/osmand_host_bridge.dart';
import 'package:endurain/features/osmand/osmand_recording_importer.dart';
import 'package:endurain/shared/state/safe_notifier.dart';

enum OsmandImportMessage {
  uploaded,
  local,
  queued,
  failed,
  accountChanged,
  importFailed,
}

class OsmandImportDestination {
  const OsmandImportDestination(this.profile);
  final ConnectionProfile? profile;
}

/// Owns saved-track loading and explicit account-bound import for one route.
class OsmandRecordingsController extends SafeNotifier {
  OsmandRecordingsController({
    required OsmandHostBridge bridge,
    required OsmandRecordingImporter importer,
    required Future<ConnectionProfile?> Function() currentProfile,
  }) : _bridge = bridge,
       _importer = importer,
       _currentProfile = currentProfile;
  final OsmandHostBridge _bridge;
  final OsmandRecordingImporter _importer;
  final Future<ConnectionProfile?> Function() _currentProfile;
  List<OsmandRecording> recordings = const [];
  bool loading = false;
  bool busy = false;
  bool loadFailed = false;
  ActivityType activityType = ActivityType.other;
  OsmandImportMessage? message;

  void selectType(ActivityType type) {
    activityType = type;
    notify();
  }

  Future<void> refresh() async {
    if (loading || busy || isDisposed) return;
    loading = true;
    loadFailed = false;
    notify();
    try {
      final loaded = await _bridge.listCompletedRecordings();
      if (!isDisposed) recordings = List.unmodifiable(loaded);
    } catch (_) {
      loadFailed = true;
    } finally {
      loading = false;
      notify();
    }
  }

  Future<OsmandImportDestination?> prepareImport() async {
    if (busy || isDisposed) return null;
    busy = true;
    message = null;
    notify();
    try {
      return OsmandImportDestination(await _currentProfile());
    } catch (_) {
      message = OsmandImportMessage.importFailed;
      cancelImport();
      return null;
    }
  }

  void cancelImport() {
    busy = false;
    notify();
  }

  Future<void> importRecording(
    OsmandRecording source,
    OsmandImportDestination destination,
  ) async {
    try {
      final current = await _currentProfile();
      final profile = destination.profile;
      if (current?.id != profile?.id || current?.origin != profile?.origin) {
        message = OsmandImportMessage.accountChanged;
        return;
      }
      if (isDisposed) return;
      final record = await _importer.importRecording(
        source,
        activityType: activityType,
        destination: profile,
      );
      final sameDestination =
          record.connectionProfileId == profile?.id &&
          record.connectionOrigin == profile?.origin;
      message = record.uploadStatus == LocalActivityUploadStatus.uploaded
          ? OsmandImportMessage.uploaded
          : profile == null || !sameDestination
          ? OsmandImportMessage.local
          : record.uploadStatus == LocalActivityUploadStatus.failed
          ? OsmandImportMessage.failed
          : OsmandImportMessage.queued;
    } catch (_) {
      message = OsmandImportMessage.importFailed;
    } finally {
      busy = false;
      notify();
    }
  }
}
