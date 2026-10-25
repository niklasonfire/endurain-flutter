import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:endurain/core/services/offline_cache_store.dart';

/// Wipes the offline read cache of the identity being left.
///
/// Cached data belongs to exactly one identity (ADR-0001): when the active
/// identity changes — signing out, switching servers via a new sign-in, or a
/// session expiry dropping the app to guest mode — the previous identity's
/// cached rows must never remain addressable. The composition root subscribes
/// this observer to `AuthSessionStore.connectionChanges`, which reports the
/// active origin-qualified profile id (`null` in guest mode).
///
/// Re-asserting the same identity — a token refresh or re-reading the stored
/// session at startup — wipes nothing: the identity did not change.
class OfflineCacheIdentityWiper {
  OfflineCacheIdentityWiper({
    required OfflineCacheStore cacheStore,
    required ValueListenable<String?> connectionChanges,
  }) : _cacheStore = cacheStore,
       _connectionChanges = connectionChanges {
    // ValueNotifier listeners do not receive the previous value, so the
    // identity active at subscription time is captured here (e.g. the session
    // restored before the composition root ran).
    _previousProfileId = connectionChanges.value;
    connectionChanges.addListener(_handleConnectionChange);
  }

  final OfflineCacheStore _cacheStore;
  final ValueListenable<String?> _connectionChanges;
  String? _previousProfileId;

  void _handleConnectionChange() {
    final currentProfileId = _connectionChanges.value;
    final previousProfileId = _previousProfileId;
    _previousProfileId = currentProfileId;
    if (previousProfileId == null || previousProfileId == currentProfileId) {
      return;
    }
    // Best-effort: a failing wipe must not break the identity transition. The
    // rows are identity-qualified on every read, so even a failed wipe can
    // never serve the previous identity's data to the next one; it only leaves
    // stale local rows behind until the next transition retries the wipe.
    unawaited(
      _cacheStore
          .clearForProfile(previousProfileId)
          .then((_) {}, onError: (_) {}),
    );
  }

  /// Stops observing identity changes.
  void dispose() {
    _connectionChanges.removeListener(_handleConnectionChange);
  }
}
