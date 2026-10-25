import 'package:endurain/core/services/offline_cache_identity_wiper.dart';
import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the per-identity wipe on identity transitions: signing out or
/// switching servers must wipe the cached data of the identity being left,
/// while other identities' cached data is untouched.
void main() {
  late _RecordingCacheStore cache;
  late ValueNotifier<String?> connection;
  late OfflineCacheIdentityWiper wiper;

  setUp(() {
    cache = _RecordingCacheStore();
    connection = ValueNotifier<String?>(null);
    wiper = OfflineCacheIdentityWiper(
      cacheStore: cache,
      connectionChanges: connection,
    );
  });

  tearDown(() {
    wiper.dispose();
    connection.dispose();
  });

  test('signing out wipes the identity being left', () async {
    connection.value = 'https://a.test#account-a';

    connection.value = null;

    await _drainWipes();
    expect(cache.clearedProfiles, ['https://a.test#account-a']);
  });

  test('switching identity wipes only the previous identity', () async {
    connection.value = 'https://a.test#account-a';

    connection.value = 'https://b.test#account-b';

    await _drainWipes();
    expect(cache.clearedProfiles, ['https://a.test#account-a']);
  });

  test('signing in from guest wipes nothing', () async {
    connection.value = 'https://a.test#account-a';

    await _drainWipes();
    expect(cache.clearedProfiles, isEmpty);
  });

  test('re-asserting the same identity wipes nothing', () async {
    connection.value = 'https://a.test#account-a';
    await _drainWipes();
    cache.clearedProfiles.clear();

    connection.value = 'https://a.test#account-a';

    await _drainWipes();
    expect(cache.clearedProfiles, isEmpty);
  });

  test('captures the identity already active at construction', () async {
    final activeConnection = ValueNotifier<String?>('https://a.test#account-a');
    final activeWiper = OfflineCacheIdentityWiper(
      cacheStore: cache,
      connectionChanges: activeConnection,
    );
    addTearDown(activeWiper.dispose);
    addTearDown(activeConnection.dispose);

    activeConnection.value = null;

    await _drainWipes();
    expect(cache.clearedProfiles, ['https://a.test#account-a']);
  });

  test('a failing wipe does not break the identity transition', () async {
    final throwingCache = _ThrowingCacheStore();
    final throwingWiper = OfflineCacheIdentityWiper(
      cacheStore: throwingCache,
      connectionChanges: connection,
    );
    addTearDown(throwingWiper.dispose);

    connection.value = 'https://a.test#account-a';
    connection.value = null;

    await _drainWipes();
    expect(throwingCache.wipeAttempts, 1);
  });
}

/// The wipe is dispatched without blocking the listener; give pending
/// microtasks a chance to run before asserting.
Future<void> _drainWipes() async {
  await Future<void>.delayed(Duration.zero);
}

class _RecordingCacheStore implements OfflineCacheStore {
  final clearedProfiles = <String>[];

  @override
  Future<int> clearForProfile(String profileId) async {
    clearedProfiles.add(profileId);
    return 1;
  }

  @override
  Future<void> clearAll() async => clearedProfiles.add('<all>');

  @override
  Future<OfflineCacheEntry?> read({
    required String profileId,
    required String concept,
    required String query,
  }) async => null;

  @override
  Future<void> write(OfflineCacheEntry entry) async {}
}

class _ThrowingCacheStore implements OfflineCacheStore {
  int wipeAttempts = 0;

  @override
  Future<int> clearForProfile(String profileId) async {
    wipeAttempts++;
    throw StateError('offline cache unavailable');
  }

  @override
  Future<void> clearAll() async {}

  @override
  Future<OfflineCacheEntry?> read({
    required String profileId,
    required String concept,
    required String query,
  }) async => null;

  @override
  Future<void> write(OfflineCacheEntry entry) async {}
}
