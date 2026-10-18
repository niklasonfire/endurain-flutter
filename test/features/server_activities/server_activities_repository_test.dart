import 'dart:async';
import 'dart:convert';

import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/base_http_client.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/repositories/api_server_activities_repository.dart';
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
      accessToken: 'access',
      refreshToken: 'refresh',
      sessionId: 's1',
      accountId: 'uuid-account',
      expiresInSeconds: 3600,
    );
  });

  ApiServerActivitiesRepository repository(
    Future<http.Response> Function(http.Request) handler,
  ) => ApiServerActivitiesRepository(
    apiClient: ApiClient(
      sessionStore: sessions,
      baseClient: BaseHttpClient(httpClient: MockClient(handler)),
    ),
    sessionStore: sessions,
  );

  test('uses numeric profile id and identical encoded filters for count and page; keeps missing metrics null', () async {
    final paths = <String>[];
    final repo = repository((request) async {
      paths.add(request.url.path);
      expect(request.headers['Authorization'], 'Bearer access');
      if (request.url.path.endsWith('/profile')) {
        return http.Response('{"id":42}', 200);
      }
      expect(request.url.queryParameters['name_search'], 'A & B');
      expect(request.url.queryParameters['type'], '1');
      expect(request.url.queryParameters['start_date'], '2026-10-01');
      expect(request.url.queryParameters['end_date'], '2026-10-18');
      if (request.url.path.endsWith('/number')) return http.Response('21', 200);
      expect(
        request.url.path,
        '/api/v1/activities/user/42/page_number/1/num_records/20',
      );
      expect(request.url.queryParameters['sort_by'], 'start_time');
      expect(request.url.queryParameters['sort_order'], 'desc');
      return http.Response(
        '[{"id":7,"name":"Morning","activity_type":1,"distance":1000,"average_hr":null}]',
        200,
      );
    });
    final page = await repo.fetchPage(
      query: ServerActivityQuery(
        search: 'A & B',
        activityType: 1,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 18),
      ),
    );
    expect(page.total, 21);
    expect(page.hasMore, isTrue);
    expect(page.items.single.distanceMeters, 1000);
    expect(page.items.single.averageHeartRate, isNull);
    expect(paths.any((p) => p.contains('streams')), isFalse);
  });
  test('maps stream 7 lat/lon, retaining zero and rejecting invalid or absent coordinates', () async {
    final repo = repository((request) async {
      expect(
        request.url.path,
        '/api/v1/activities_streams/activity_id/7/stream_type/7',
      );
      return http.Response(
        jsonEncode({
          'activity_id': 7,
          'stream_type': 7,
          'stream_waypoints': [
            {'lat': 52.5, 'lon': 13.4},
            {'lat': 0, 'lon': 0},
            {'lat': null, 'lon': 13.4},
            {'lat': 91, 'lon': 13},
            {'lat': 50, 'lon': 181},
            {'lat': '52', 'lon': '13'},
          ],
        }),
        200,
      );
    });
    final route = await repo.fetchRoute(7);
    expect(route.map((p) => p.latitude), [52.5, 0]);
    expect(route.map((p) => p.longitude), [13.4, 0]);
  });

  test('late detail response from previous account is rejected', () async {
    final pending = Completer<http.Response>();
    final started = Completer<void>();
    final repo = repository((request) {
      started.complete();
      return pending.future;
    });
    final future = repo.fetchDetail(7);
    await started.future;
    await sessions.saveSession(
      origin: 'https://example.test',
      accessToken: 'other',
      refreshToken: 'other-refresh',
      sessionId: 's2',
      accountId: 'other-account',
      expiresInSeconds: 3600,
    );
    pending.complete(
      http.Response('{"id":7,"name":"Private","activity_type":1}', 200),
    );
    await expectLater(
      future,
      throwsA(
        isA<AppException>().having(
          (e) => e.code,
          'code',
          AppErrorCode.sessionExpired,
        ),
      ),
    );
  });

  test('types keys are numeric ids; null stream means no GPS', () async {
    final repo = repository(
      (request) async => http.Response(
        request.url.path.endsWith('/types')
            ? '{"12":"Hike","1":"Run"}'
            : 'null',
        200,
      ),
    );
    expect(await repo.fetchActivityTypes(), [1, 12]);
    expect(await repo.fetchRoute(7), isEmpty);
  });

  test('detail preserves measured zero, optional null and UTC dates without an offset', () async {
    final repo = repository(
      (request) async => http.Response(
        '{"id":7,"name":"Ride","activity_type":2,"distance":0,"start_time":"2026-10-18T09:30:00","average_hr":null,"average_power":125}',
        200,
      ),
    );
    final detail = await repo.fetchDetail(7);
    expect(detail.distanceMeters, 0);
    expect(detail.averageHeartRate, isNull);
    expect(detail.averagePower, 125);
    expect(detail.startTime, DateTime.utc(2026, 10, 18, 9, 30));
    expect(detail.startTime!.isUtc, isTrue);
  });

  test(
    'malformed envelopes and server errors surface typed failures',
    () async {
      final malformed = repository((request) async => http.Response('[]', 200));
      await expectLater(
        malformed.fetchDetail(7),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpectedResponseFormat,
          ),
        ),
      );
      final failed = repository(
        (request) async =>
            http.Response('{"detail":"private diagnostic"}', 500),
      );
      await expectLater(
        failed.fetchDetail(7),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.serverActivitiesFetchFailed,
          ),
        ),
      );
    },
  );

  test('transport failures surface a typed activity load error', () async {
    final repo = repository(
      (request) async => throw http.ClientException('connection unavailable'),
    );
    await expectLater(
      repo.fetchDetail(7),
      throwsA(
        isA<AppException>().having(
          (e) => e.code,
          'code',
          AppErrorCode.serverActivitiesFetchFailed,
        ),
      ),
    );
  });
}
