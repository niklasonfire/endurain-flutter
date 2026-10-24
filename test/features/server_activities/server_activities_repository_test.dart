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
import 'package:intl/intl.dart';

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

  test('late graph response cannot cross account switch', () async {
    final pending = Completer<http.Response>();
    final started = Completer<void>();
    final repo = repository((request) {
      started.complete();
      return pending.future;
    });
    final result = repo.fetchGraphs(7);
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
      http.Response(
        '[{"activity_id":7,"stream_type":1,"stream_waypoints":[{"hr":123}]}]',
        200,
      ),
    );
    await expectLater(result, throwsA(isA<AppException>()));
  });

  test(
    'graphs reject wrong activity ids and malformed metric arrays',
    () async {
      final wrongOwner = repository(
        (_) async => http.Response(
          '[{"activity_id":8,"stream_type":1,"stream_waypoints":[]}]',
          200,
        ),
      );
      await expectLater(
        wrongOwner.fetchGraphs(7),
        throwsA(isA<AppException>()),
      );
      final malformed = repository(
        (_) async => http.Response(
          '[{"activity_id":7,"stream_type":1,"stream_waypoints":{}}]',
          200,
        ),
      );
      await expectLater(malformed.fetchGraphs(7), throwsA(isA<AppException>()));
    },
  );

  test(
    'loads exact stream and lap endpoints and validates account ownership',
    () async {
      final repo = repository((request) async {
        if (request.url.path ==
            '/api/v1/activities_streams/activity_id/7/all') {
          return http.Response(
            '[{"activity_id":7,"stream_type":1,"stream_waypoints":[{"time":"2026-10-18T10:00:00Z","hr":123}]}]',
            200,
          );
        }
        expect(request.url.path, '/api/v1/activities_laps/activity_id/7/all');
        return http.Response(
          '[{"activity_id":7,"total_distance":1000,"total_timer_time":300,"avg_heart_rate":145}]',
          200,
        );
      });
      expect((await repo.fetchGraphs(7)).single.points().single.value, 123);
      final lap = (await repo.fetchLaps(7)).single;
      expect(lap.distanceMeters, 1000);
      expect(lap.speed, closeTo(3.333333, 0.000001));
      expect(lap.heartRate, 145);
    },
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
            {'lat': 52.5, 'lon': 13.4, 'time': '2026-10-18T10:00:00'},
            {'lat': 0, 'lon': 0, 'time': '2026-10-18T12:00:10+02:00'},
            {'lat': null, 'lon': 13.4},
            {'lat': 91, 'lon': 13},
            {'lat': 50, 'lon': 181},
            {'lat': '52', 'lon': '13'},
            {'lat': 51, 'lon': 12},
          ],
        }),
        200,
      );
    });
    final route = await repo.fetchRoute(7);
    expect(route.map((p) => p.latitude), [52.5, 0, 51]);
    expect(route.map((p) => p.longitude), [13.4, 0, 12]);
    expect(route.map((p) => p.startsSegment), [false, false, true]);
    expect(route[0].time, DateTime.utc(2026, 10, 18, 10));
    expect(route[1].time, DateTime.utc(2026, 10, 18, 10, 0, 10));
    expect(route[2].time, isNull);
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

  test('detail preserves measured zero, optional null and offset-free display dates', () async {
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
    expect(detail.startTime, isNull);
    expect(
      detail.displayStartTime!.format(DateFormat('yyyy-MM-dd HH:mm')),
      '2026-10-18 09:30',
    );
  });

  test('detail renders the start time in the recorded IANA timezone', () async {
    final repo = repository(
      (request) async => http.Response(
        '{"id":7,"name":"Ride","activity_type":2,"start_time":"2026-10-18T15:15:35Z","timezone":"America/New_York"}',
        200,
      ),
    );
    final detail = await repo.fetchDetail(7);
    expect(detail.startTime, DateTime.utc(2026, 10, 18, 15, 15, 35));
    expect(
      detail.displayStartTime!.format(DateFormat('yyyy-MM-dd HH:mm')),
      '2026-10-18 11:15',
    );
  });

  test('detail without a timezone field keeps device-local display', () async {
    final repo = repository(
      (request) async => http.Response(
        '{"id":7,"name":"Ride","activity_type":2,"start_time":"2026-10-18T15:15:35Z"}',
        200,
      ),
    );
    final detail = await repo.fetchDetail(7);
    expect(
      detail.displayStartTime!.format(DateFormat('yyyy-MM-dd HH:mm')),
      DateFormat('yyyy-MM-dd HH:mm').format(
        DateTime.utc(2026, 10, 18, 15, 15, 35).toLocal(),
      ),
    );
  });

  test('recorded timezone cannot resurrect a masked start time', () async {
    final repo = repository(
      (request) async => http.Response(
        '{"id":7,"name":"Ride","activity_type":2,"start_time":null,"timezone":"America/New_York"}',
        200,
      ),
    );
    final detail = await repo.fetchDetail(7);
    expect(detail.startTime, isNull);
    expect(detail.displayStartTime, isNull);
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

  test('guest activity requests fail before contacting a server', () async {
    await sessions.clear();
    var requests = 0;
    final repo = repository((request) async {
      requests++;
      return http.Response('{}', 200);
    });
    for (final operation in [
      () => repo.fetchPage(),
      () => repo.fetchActivityTypes(),
      () => repo.fetchDetail(7),
      () => repo.fetchRoute(7),
    ]) {
      await expectLater(
        operation(),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            AppErrorCode.notAuthenticated,
          ),
        ),
      );
    }
    expect(requests, 0);
  });

  test(
    'logout during count rejects the result before loading private rows',
    () async {
      final countStarted = Completer<void>();
      final countResponse = Completer<http.Response>();
      final paths = <String>[];
      final repo = repository((request) {
        paths.add(request.url.path);
        if (request.url.path.endsWith('/profile')) {
          return Future.value(http.Response('{"id":42}', 200));
        }
        countStarted.complete();
        return countResponse.future;
      });
      final page = repo.fetchPage();
      await countStarted.future;
      await sessions.clear();
      countResponse.complete(http.Response('1', 200));
      await expectLater(
        page,
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            AppErrorCode.sessionExpired,
          ),
        ),
      );
      expect(paths, ['/api/v1/profile', '/api/v1/activities/number']);
    },
  );

  test('route rejects a stream belonging to another activity', () async {
    final repo = repository(
      (request) async => http.Response(
        '{"activity_id":8,"stream_type":7,"stream_waypoints":[]}',
        200,
      ),
    );
    await expectLater(
      repo.fetchRoute(7),
      throwsA(
        isA<AppException>().having(
          (error) => error.code,
          'code',
          AppErrorCode.unexpectedResponseFormat,
        ),
      ),
    );
  });

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
