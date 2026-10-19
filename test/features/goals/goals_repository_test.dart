import 'dart:convert';

import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/base_http_client.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/features/goals/repositories/api_goals_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthSessionStore sessions;
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    sessions = AuthSessionStore(storage: SecureStorageService());
    await sessions.saveSession(
      origin: 'https://example.test',
      accessToken: 'a',
      refreshToken: 'r',
      sessionId: 's',
      accountId: 'u',
      expiresInSeconds: 3600,
    );
  });
  ApiGoalsRepository repository(
    Future<http.Response> Function(http.Request) handler,
  ) => ApiGoalsRepository(
    apiClient: ApiClient(
      sessionStore: sessions,
      baseClient: BaseHttpClient(httpClient: MockClient(handler)),
    ),
    sessionStore: sessions,
  );
  test(
    'reads server goal results and keeps duration in elapsed seconds',
    () async {
      final repo = repository((request) async {
        expect(request.url.path, '/api/v1/profile/goals/results');
        return http.Response(
          jsonEncode([
            {
              'goal_id': 7,
              'interval': 'weekly',
              'activity_type': 'run',
              'goal_type': 'duration',
              'start_date': '2026-10-19',
              'end_date': '2026-10-25',
              'percentage_completed': 75,
              'goal_duration': 7200,
              'total_duration': 5400,
            },
          ]),
          200,
        );
      });
      final goal = (await repo.fetchResults()).single;
      expect(goal.target, 7200);
      expect(goal.achieved, 5400);
      expect(goal.progress, .75);
      expect(goal.isAchieved, false);
      expect(goal.startDate, DateTime.utc(2026, 10, 19));
    },
  );
  test('server null represents no goals', () async {
    final repo = repository((request) async => http.Response('null', 200));
    expect(await repo.fetchResults(), isEmpty);
  });
}
