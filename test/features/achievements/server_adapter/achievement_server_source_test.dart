import 'dart:convert';
import 'dart:async';

import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/base_http_client.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/features/achievements/services/achievement_server_source.dart';
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
      accountId: '42',
      expiresInSeconds: 3600,
    );
  });
  ApiAchievementServerSource source(Map<String, Object?> responses) =>
      ApiAchievementServerSource(
        sessionStore: sessions,
        apiClient: ApiClient(
          sessionStore: sessions,
          baseClient: BaseHttpClient(
            httpClient: MockClient(
              (request) async =>
                  http.Response(jsonEncode(responses[request.url.path]), 200),
            ),
          ),
        ),
      );
  test('raw UTC calendar and timer duration override display values', () async {
    final api = source({
      '/api/v1/activities/user/42/page_number/1/num_records/100': [
        {
          'id': 9,
          'activity_type': 1,
          'start_time': '2026-01-01T23:30:00',
          'start_time_tz_applied': '2026-01-02T01:30:00',
          'distance': 1000,
          'total_timer_time': 400,
          'total_elapsed_time': 500,
        },
      ],
    });
    final session = (await sessions.readSession())!;
    final activities = await api.fetchPage(session, userId: 42, page: 1);
    expect(activities.single.startedAt, DateTime.utc(2026, 1, 1, 23, 30));
    expect(activities.single.durationSeconds, 400);
  });
  test(
    'GPS estimates preserve stops and split gaps, invalid fixes and jumps',
    () async {
      final api = source({
        '/api/v1/activities/user/42/page_number/1/num_records/100': [
          {'id': 9, 'activity_type': 1, 'distance': 99999},
        ],
        '/api/v1/activities_streams/activity_id/9/stream_type/7': {
          'activity_id': 9,
          'stream_type': 7,
          'stream_waypoints': [
            {'lat': 0, 'lon': 0, 'time': '2026-01-01T00:00:00Z'},
            {'lat': 0, 'lon': 0.001, 'time': '2026-01-01T00:00:10Z'},
            {'lat': 0, 'lon': 0.001, 'time': '2026-01-01T00:00:20Z'},
            {'lat': 0, 'lon': 0.002, 'time': '2026-01-01T00:01:21Z'},
            {'lat': 999, 'lon': 0, 'time': '2026-01-01T00:01:22Z'},
            {'lat': 0, 'lon': 0.003, 'time': '2026-01-01T00:01:23Z'},
            {'lat': 0, 'lon': 1, 'time': '2026-01-01T00:01:24Z'},
          ],
        },
      });
      final session = (await sessions.readSession())!;
      final activity = (await api.fetchPage(
        session,
        userId: 42,
        page: 1,
      )).single;
      final track = await api.fetchTrack(session, activity);
      expect(track.activity.samples[1].distanceMeters, closeTo(111.319, 0.01));
      expect(
        track.activity.samples[2].distanceMeters,
        track.activity.samples[1].distanceMeters,
      );
      expect(
        track.activity.samples[2].timestamp
            .difference(track.activity.samples[1].timestamp)
            .inSeconds,
        10,
      );
      expect(
        track.activity.samples[3].segmentId,
        isNot(track.activity.samples[2].segmentId),
      );
      expect(
        track.reasons,
        containsAll(['invalidGpsPoint', 'gpsGap', 'gpsJump']),
      );
    },
  );
  test(
    'wrong stream identity fails instead of inventing an unavailable track',
    () async {
      final api = source({
        '/api/v1/activities/user/42/page_number/1/num_records/100': [
          {'id': 9, 'activity_type': 1},
        ],
        '/api/v1/activities_streams/activity_id/9/stream_type/7': {
          'activity_id': 10,
          'stream_type': 7,
          'stream_waypoints': <Object?>[],
        },
      });
      final session = (await sessions.readSession())!;
      final activity = (await api.fetchPage(
        session,
        userId: 42,
        page: 1,
      )).single;
      await expectLater(
        api.fetchTrack(session, activity),
        throwsA(isA<AppException>()),
      );
    },
  );
  test(
    'null detail is confirmed absence but forbidden and failures retain source',
    () async {
      final session = (await sessions.readSession())!;
      final api = source({'/api/v1/activities/9': null});
      expect(await api.isDeleted(session, 9), true);
      for (final status in [403, 500]) {
        final failing = ApiAchievementServerSource(
          sessionStore: sessions,
          apiClient: ApiClient(
            sessionStore: sessions,
            baseClient: BaseHttpClient(
              httpClient: MockClient((_) async => http.Response('{}', status)),
            ),
          ),
        );
        await expectLater(
          failing.isDeleted(session, 9),
          throwsA(isA<AppException>()),
        );
      }
    },
  );
  test('late account response is rejected at the adapter boundary', () async {
    final pending = Completer<http.Response>();
    final api = ApiAchievementServerSource(
      sessionStore: sessions,
      apiClient: ApiClient(
        sessionStore: sessions,
        baseClient: BaseHttpClient(
          httpClient: MockClient((_) => pending.future),
        ),
      ),
    );
    final session = (await sessions.readSession())!;
    final request = api.fetchOwner(session);
    await Future<void>.delayed(Duration.zero);
    await sessions.clear();
    pending.complete(
      http.Response('{"id":42,"first_day_of_week":"monday"}', 200),
    );
    await expectLater(request, throwsA(isA<AppException>()));
  });
}
