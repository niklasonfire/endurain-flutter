import 'dart:convert';

import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/base_http_client.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/features/achievements/controllers/achievements_controller.dart';
import 'package:endurain/features/achievements/repositories/local_achievements_repository.dart';
import 'package:endurain/features/achievements/repositories/sqflite_achievement_store.dart';
import 'package:endurain/features/achievements/services/achievement_scan_service.dart';
import 'package:endurain/features/achievements/services/achievement_server_source.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  test(
    'filters disappear when refresh removes their last source activity',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final sessions = AuthSessionStore(storage: SecureStorageService());
      await sessions.saveSession(
        origin: 'https://example.test',
        accessToken: 'a',
        refreshToken: 'r',
        sessionId: 's',
        accountId: '42',
        expiresInSeconds: 3600,
      );
      var deleted = false;
      final api = ApiClient(
        sessionStore: sessions,
        baseClient: BaseHttpClient(
          httpClient: MockClient((request) async {
            final path = request.url.path;
            final Object? value = path.endsWith('/profile')
                ? {'id': 42, 'first_day_of_week': 'monday'}
                : path.endsWith('/number')
                ? (deleted ? 0 : 1)
                : path.contains('/page_number/')
                ? (deleted
                      ? <Object?>[]
                      : [
                          {
                            'id': 1,
                            'activity_type': 1,
                            'distance': 5000,
                            'start_time': '2025-01-01T12:00:00',
                          },
                        ])
                : null;
            return http.Response(jsonEncode(value), 200);
          }),
        ),
      );
      final repo = LocalAchievementsRepository(
        store: SqfliteAchievementStore(
          databaseFactory: databaseFactoryFfi,
          databasePath: inMemoryDatabasePath,
        ),
      );
      final scanner = AchievementScanService(
        repository: repo,
        source: ApiAchievementServerSource(
          apiClient: api,
          sessionStore: sessions,
        ),
        sessionStore: sessions,
      );
      final controller = AchievementsController(scanService: scanner);
      addTearDown(() async {
        controller.dispose();
        scanner.dispose();
        await repo.close();
      });
      await controller.initialize();
      await controller.refresh();
      await controller.setSport(1);
      await controller.setYear(2025);
      expect(controller.records, isNotEmpty);
      deleted = true;
      await controller.refresh();
      expect(controller.selectedSport, isNull);
      expect(controller.selectedYear, isNull);
      expect(controller.records, isEmpty);
    },
  );
}
