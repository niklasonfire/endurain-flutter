import 'dart:convert';

import 'package:endurain/core/services/app_preferences_store.dart';
import 'package:endurain/features/activity/models/local_activity_record.dart';

/// Provenance independent of deletable local-history rows and GPX copies.
/// No public reset: deleting local history must not reassign a source account.
class OsmandImportLedger {
  OsmandImportLedger(this._preferences);
  final AppPreferencesStore _preferences;
  String _key(String contentId) => 'osmand.import.provenance.$contentId';

  Future<bool> contains(String contentId) async =>
      await _preferences.read(key: _key(contentId)) != null;

  Future<void> remember(LocalActivityRecord record) => _preferences.write(
    key: _key(record.id),
    value: jsonEncode({
      'origin': record.connectionOrigin,
      'profileId': record.connectionProfileId,
    }),
  );
}

/// The original was already imported; its local row was subsequently deleted.
class OsmandPreviouslyImported implements Exception {
  const OsmandPreviouslyImported();
}
