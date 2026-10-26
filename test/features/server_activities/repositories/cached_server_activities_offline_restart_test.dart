import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';

import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_service.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/base_http_client.dart';
import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/repositories/api_server_activities_repository.dart';
import 'package:endurain/features/server_activities/repositories/cached_server_activities_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test(
    'serves the cached activity list when the app restarts offline and the '
    'access token needs a refresh',
    () async {
      // State persisted by the earlier online session: a stored session whose
      // access token has fallen inside the proactive-refresh window (a restart
      // hours after the last fetch), and the activity list previously written
      // through the cache.
      final storage = SecureStorageService();
      final sessionStore = AuthSessionStore(storage: storage);
      await sessionStore.saveSession(
        origin: 'https://example.test',
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        sessionId: 'session-1',
        accountId: '42',
        expiresInSeconds: 30,
      );
      final profile = await sessionStore.getConnectionProfile();
      expect(profile, isNotNull);

      final store = _FakeStore();
      await store.write(
        OfflineCacheEntry(
          profileId: profile!.id,
          concept: 'activity-list',
          query: canonicalCacheQuery(
            ApiServerActivitiesRepository.activityListQueryParameters(
              query: const ServerActivityQuery(),
              page: 1,
              pageSize: 20,
            ),
          ),
          payload: {
            'items': [
              {'id': 1, 'activity_type': 1, 'name': 'Morning run'},
            ],
            'total': 1,
          },
          fetchedAt: DateTime(2026, 10, 25, 18, 0).toUtc(),
        ),
      );

      // The restarted app has no network: every request, including the token
      // refresh, fails at transport level.
      final offlineClient = MockClient((request) async {
        throw const SocketException('no network');
      });
      final apiClient = ApiClient(
        storage: storage,
        authService: AuthService(storage: storage, httpClient: offlineClient),
        baseClient: BaseHttpClient(httpClient: offlineClient),
      );

      final repository = CachedServerActivitiesRepository(
        inner: ApiServerActivitiesRepository(
          apiClient: apiClient,
          sessionStore: sessionStore,
        ),
        cacheStore: store,
        connectionProfile: sessionStore.getConnectionProfile,
      );

      final page = await repository.fetchPage();

      expect(page.total, 1);
      expect(page.items.single.name, 'Morning run');
    },
  );
}

class _FakeStore implements OfflineCacheStore {
  final Map<String, OfflineCacheEntry> entries = {};

  @override
  Future<OfflineCacheEntry?> read({
    required String profileId,
    required String concept,
    required String query,
  }) async =>
      entries[offlineCacheKey(
        profileId: profileId,
        concept: concept,
        query: query,
      )];

  @override
  Future<void> write(OfflineCacheEntry entry) async {
    entries[offlineCacheKey(
      profileId: entry.profileId,
      concept: entry.concept,
      query: entry.query,
    )] = entry;
  }

  @override
  Future<int> clearForProfile(String profileId) async {
    final doomed =
        entries.keys.where((key) => entries[key]!.profileId == profileId);
    entries.removeWhere((key, value) => value.profileId == profileId);
    return doomed.length;
  }

  @override
  Future<void> clearAll() async {
    entries.clear();
  }
}
