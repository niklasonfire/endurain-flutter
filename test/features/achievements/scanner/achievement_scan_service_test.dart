import 'dart:convert';
import 'dart:async';

import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/features/achievements/controllers/achievements_controller.dart';

import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/base_http_client.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/features/achievements/services/achievement_server_source.dart';
import 'package:endurain/features/achievements/services/achievement_scan_service.dart';
import 'package:endurain/features/achievements/repositories/achievements_repository.dart';
import 'package:endurain/features/achievements/repositories/local_achievements_repository.dart';
import 'package:endurain/features/achievements/repositories/sqflite_achievement_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  test(
    'scans all server history and produces summary records when GPS is absent',
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
      final api = ApiClient(
        sessionStore: sessions,
        baseClient: BaseHttpClient(
          httpClient: MockClient((request) async {
            final path = request.url.path;
            final Object? value = path == '/api/v1/profile'
                ? {'id': 42, 'first_day_of_week': 'sunday'}
                : path.endsWith('/number')
                ? 1
                : path.contains('/page_number/')
                ? [
                    {
                      'id': 1,
                      'activity_type': 1,
                      'distance': 5000,
                      'total_timer_time': 1500,
                      'start_time': '2026-10-01T12:00:00',
                    },
                  ]
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
      final service = AchievementScanService(
        repository: repo,
        source: ApiAchievementServerSource(
          apiClient: api,
          sessionStore: sessions,
        ),
        sessionStore: sessions,
      );
      addTearDown(() async {
        service.dispose();
        await repo.close();
      });
      await service.initialize();
      expect(service.snapshot?.analyses, isEmpty);
      await service.scan();
      expect(
        service.snapshot!.scanState!.status,
        AchievementScanStatus.complete,
      );
      expect(
        service.snapshot!.records.any((r) => r.winner.value == 5000),
        isTrue,
      );
      expect(service.snapshot!.scanState!.unavailableTrackCount, 1);
      expect(service.snapshot!.scanState!.firstDayOfWeek, DateTime.sunday);
    },
  );
  test(
    'opening a route during a scan observes the same scan without cancelling',
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
      final pending = Completer<http.Response>();
      final reached = Completer<void>();
      final api = ApiClient(
        sessionStore: sessions,
        baseClient: BaseHttpClient(
          httpClient: MockClient((request) async {
            if (request.url.path == '/api/v1/profile') {
              reached.complete();
              return pending.future;
            }
            return http.Response(
              request.url.path.endsWith('/number') ? '0' : '[]',
              200,
            );
          }),
        ),
      );
      final repo = LocalAchievementsRepository(
        store: SqfliteAchievementStore(
          databaseFactory: databaseFactoryFfi,
          databasePath: inMemoryDatabasePath,
        ),
      );
      final service = AchievementScanService(
        repository: repo,
        source: ApiAchievementServerSource(
          apiClient: api,
          sessionStore: sessions,
        ),
        sessionStore: sessions,
      );
      addTearDown(() async {
        service.dispose();
        await repo.close();
      });
      await service.initialize();
      final scan = service.scan();
      await reached.future;
      await service.initialize();
      pending.complete(
        http.Response('{"id":42,"first_day_of_week":"monday"}', 200),
      );
      await scan;
      expect(service.isScanning, false);
      expect(
        service.snapshot!.scanState!.status,
        AchievementScanStatus.complete,
      );
    },
  );

  Future<
    ({
      AchievementScanService service,
      LocalAchievementsRepository repo,
      AuthSessionStore sessions,
    })
  >
  setup(Future<http.Response> Function(http.Request) handler) async {
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
    final api = ApiClient(
      sessionStore: sessions,
      baseClient: BaseHttpClient(httpClient: MockClient(handler)),
    );
    final repo = LocalAchievementsRepository(
      store: SqfliteAchievementStore(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      ),
    );
    final service = AchievementScanService(
      repository: repo,
      source: ApiAchievementServerSource(
        apiClient: api,
        sessionStore: sessions,
      ),
      sessionStore: sessions,
    );
    addTearDown(() async {
      service.dispose();
      await repo.close();
    });
    await service.initialize();
    return (service: service, repo: repo, sessions: sessions);
  }

  test(
    'scan failures expose a typed error and preserve the network cause',
    () async {
      final fixture = await setup(
        (_) async => http.Response('unavailable', 500),
      );
      await fixture.service.scan();
      expect(
        fixture.service.error,
        isA<AppException>()
            .having((error) => error.code.name, 'code', 'achievementScanFailed')
            .having(
              (error) => error.cause,
              'cause',
              isA<AppException>().having(
                (cause) => cause.code,
                'code',
                AppErrorCode.serverActivitiesFetchFailed,
              ),
            ),
      );
      expect(
        fixture.service.snapshot!.scanState!.error,
        'achievementScanFailed',
      );
      final controller = AchievementsController(scanService: fixture.service);
      addTearDown(controller.dispose);
      expect(controller.error, same(fixture.service.error));
    },
  );

  final activity = {
    'id': 1,
    'activity_type': 1,
    'distance': 5000,
    'total_timer_time': 1500,
    'start_time': '2026-10-01T12:00:00',
  };
  test(
    'unstable pagination and unconfirmed deletion retain cached winners',
    () async {
      var mode = 'initial';
      final env = await setup((request) async {
        final path = request.url.path;
        Object? result;
        if (path.endsWith('/profile')) {
          result = {'id': 42, 'first_day_of_week': 'monday'};
        } else if (path.endsWith('/number')) {
          result = mode == 'initial'
              ? 1
              : mode == 'duplicates'
              ? 2
              : 0;
        } else if (path.contains('/page_number/')) {
          result = mode == 'initial'
              ? [activity]
              : mode == 'duplicates'
              ? [activity, activity]
              : [];
        } else if (path == '/api/v1/activities/1' && mode == 'forbidden') {
          return http.Response('{}', 403);
        }
        return http.Response(jsonEncode(result), 200);
      });
      await env.service.scan();
      expect(env.service.snapshot!.analyses.length, 1);
      mode = 'duplicates';
      await env.service.scan();
      expect(env.service.snapshot!.analyses.length, 1);
      expect(
        env.service.snapshot!.scanState!.status,
        AchievementScanStatus.failed,
      );
      mode = 'forbidden';
      await env.service.scan();
      expect(env.service.snapshot!.analyses.length, 1);
      expect(
        env.service.snapshot!.scanState!.status,
        AchievementScanStatus.partial,
      );
      mode = 'deleted';
      await env.service.scan();
      expect(env.service.snapshot!.analyses, isEmpty);
      expect(
        env.service.snapshot!.scanState!.status,
        AchievementScanStatus.complete,
      );
    },
  );
  test(
    'failed rebuild retains old summary and retries the changed activity',
    () async {
      var mode = 'initial';
      final env = await setup((request) async {
        final path = request.url.path;
        Object? result;
        if (path.endsWith('/profile')) {
          result = {'id': 42, 'first_day_of_week': 'monday'};
        } else if (path.endsWith('/number')) {
          result = 1;
        } else if (path.contains('/page_number/')) {
          result = [
            {...activity, 'distance': mode == 'initial' ? 5000 : 6000},
          ];
        } else if (mode == 'failure') {
          return http.Response('{}', 500);
        }
        return http.Response(jsonEncode(result), 200);
      });
      await env.service.scan();
      mode = 'failure';
      await env.service.scan(rebuild: true);
      expect(
        env.service.snapshot!.analyses.single.activity.distanceMeters,
        5000,
      );
      expect(
        env.service.snapshot!.scanState!.status,
        AchievementScanStatus.partial,
      );
      mode = 'recovered';
      await env.service.scan();
      expect(
        env.service.snapshot!.analyses.single.activity.distanceMeters,
        6000,
      );
      expect(
        env.service.snapshot!.scanState!.status,
        AchievementScanStatus.complete,
      );
    },
  );
  test(
    'late GPS from a previous account never repopulates visible records',
    () async {
      final pending = Completer<http.Response>();
      final reached = Completer<void>();
      final env = await setup((request) async {
        final path = request.url.path;
        if (path.endsWith('/profile')) {
          return http.Response('{"id":42,"first_day_of_week":"monday"}', 200);
        }
        if (path.endsWith('/number')) return http.Response('1', 200);
        if (path.contains('/page_number/')) {
          return http.Response(jsonEncode([activity]), 200);
        }
        reached.complete();
        return pending.future;
      });
      final scan = env.service.scan();
      await reached.future;
      await env.sessions.saveSession(
        origin: 'https://other.test',
        accessToken: 'b',
        refreshToken: 'r',
        sessionId: 's2',
        accountId: '42',
        expiresInSeconds: 3600,
      );
      expect(env.service.snapshot, isNull);
      pending.complete(http.Response('null', 200));
      await scan;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(env.service.snapshot?.analyses ?? [], isEmpty);
      expect(env.service.isScanning, false);
    },
  );
  test('cancelled rebuild resumes pending raw inputs without losing cached work', () async {
    var mode = 'initial';
    final waiting = Completer<http.Response>();
    final reached = Completer<void>();
    final env = await setup((request) async {
      final path = request.url.path;
      if (path.endsWith('/profile')) {
        return http.Response('{"id":42,"first_day_of_week":"monday"}', 200);
      }
      if (path.endsWith('/number')) return http.Response('2', 200);
      if (path.contains('/page_number/')) {
        return http.Response(
          jsonEncode([
            activity,
            {...activity, 'id': 2},
          ]),
          200,
        );
      }
      if (mode == 'rebuild' && path.contains('/activity_id/2/')) {
        reached.complete();
        return waiting.future;
      }
      return http.Response(
        'null',
        mode == 'resume' && path.contains('/activity_id/2/') ? 500 : 200,
      );
    });
    await env.service.scan();
    mode = 'rebuild';
    final rebuild = env.service.scan(rebuild: true);
    await reached.future;
    await env.service.cancel();
    waiting.complete(http.Response('null', 200));
    await rebuild;
    expect(
      env.service.snapshot!.scanState!.status,
      AchievementScanStatus.partial,
    );
    expect(env.service.snapshot!.scanState!.pendingRebuildIds, [2]);
    mode = 'resume';
    await env.service.scan();
    // A summary fingerprint matches the old cache, but this raw track is still
    // pending from the interrupted rebuild and must surface the server failure.
    expect(
      env.service.snapshot!.scanState!.status,
      AchievementScanStatus.partial,
    );
    expect(env.service.snapshot!.scanState!.failures.keys, contains(2));
    expect(env.service.snapshot!.analyses.length, 2);
  });
  test('interrupting inventory preserves failed-track retries and unavailable coverage', () async {
    var mode = 'initial';
    final pending = Completer<http.Response>();
    final reached = Completer<void>();
    final rows = [
      activity,
      {...activity, 'id': 2},
    ];
    final env = await setup((request) async {
      final path = request.url.path;
      if (path.endsWith('/profile')) {
        return http.Response('{"id":42,"first_day_of_week":"monday"}', 200);
      }
      if (path.endsWith('/number')) {
        return http.Response(mode == 'deleted' ? '0' : '2', 200);
      }
      if (path.contains('/page_number/')) {
        if (mode == 'interrupt') {
          reached.complete();
          return pending.future;
        }
        return http.Response(
          jsonEncode(mode == 'deleted' ? <Object?>[] : rows),
          200,
        );
      }
      if (path.contains('/activity_id/1/')) {
        return http.Response('{}', mode == 'recovered' ? 200 : 500);
      }
      return http.Response('null', 200);
    });
    await env.service.scan();
    expect(env.service.snapshot!.scanState!.failures.keys, contains(1));
    expect(
      env.service.snapshot!.scanState!.skipped[2],
      contains('gpsUnavailable'),
    );
    mode = 'interrupt';
    final refresh = env.service.scan();
    await reached.future;
    await env.service.cancel();
    pending.complete(http.Response(jsonEncode(rows), 200));
    await refresh;
    expect(env.service.snapshot!.scanState!.failures.keys, contains(1));
    expect(
      env.service.snapshot!.scanState!.skipped[2],
      contains('gpsUnavailable'),
    );
    mode = 'resume';
    await env.service.scan();
    expect(env.service.snapshot!.scanState!.failures.keys, contains(1));
    expect(
      env.service.snapshot!.scanState!.status,
      AchievementScanStatus.partial,
    );
    expect(env.service.snapshot!.scanState!.unavailableTrackCount, 1);
    mode = 'deleted';
    await env.service.scan();
    expect(
      env.service.snapshot!.scanState!.status,
      AchievementScanStatus.complete,
    );
    expect(env.service.snapshot!.scanState!.failures, isEmpty);
    expect(env.service.snapshot!.scanState!.skipped, isEmpty);
  });
}
