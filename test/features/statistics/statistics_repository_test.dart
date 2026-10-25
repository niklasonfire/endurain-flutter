import 'dart:async';

import 'package:endurain/core/models/app_exception.dart';

import 'dart:convert';

import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/base_http_client.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/api_statistics_repository.dart';
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

  ApiStatisticsRepository repository(
    Future<http.Response> Function(http.Request) handler,
  ) => ApiStatisticsRepository(
    apiClient: ApiClient(
      sessionStore: sessions,
      baseClient: BaseHttpClient(httpClient: MockClient(handler)),
    ),
    sessionStore: sessions,
  );

  test(
    'uses full server aggregate and excludes gym distance from total',
    () async {
      final repo = repository((request) async {
        expect(request.url.path, '/api/v1/activities/summaries');
        expect(request.url.queryParameters['period'], 'month');
        expect(request.url.queryParameters['date'], '2026-10-18');
        return http.Response(
          jsonEncode({
            'total_distance': 12000,
            'total_duration': 7200,
            'total_elevation_gain': 120,
            'activity_count': 100,
            'breakdown': [
              {
                'week_number': 3,
                'total_distance': 12000,
                'total_duration': 7200,
                'total_elevation_gain': 120,
                'activity_count': 100,
              },
            ],
            'type_breakdown': [
              {
                'activity_type_id': 1,
                'activity_type': 'Run',
                'total_distance': 10000,
                'total_duration': 3600,
                'total_elevation_gain': 120,
                'activity_count': 50,
              },
              {
                'activity_type_id': 19,
                'activity_type': 'Strength training',
                'total_distance': 2000,
                'total_duration': 3600,
                'total_elevation_gain': 0,
                'activity_count': 50,
              },
            ],
          }),
          200,
        );
      });
      final result = await repo.fetch(
        StatisticsQuery(
          period: StatisticsPeriod.month,
          date: DateTime(2026, 10, 18),
        ),
      );
      expect(result.totals.count, 100);
      expect(result.distanceMeters, 10000);
      expect(result.buckets.single.index, 3);
      expect(result.sports.last.hasDistance, isFalse);
    },
  );
  for (final period in StatisticsPeriod.values) {
    test(
      'running filter preserves aggregate totals for ${period.name}',
      () async {
        final repo = repository((request) async {
          expect(request.url.path, '/api/v1/activities/summaries');
          expect(request.url.queryParameters['period'], period.name);
          // v0.20.1 type_breakdown labels every type with a display name
          // built by backend set_activity_name_based_on_activity_type
          // (summary_crud.py): the canonical name plus a trailing
          // " workout", except "Workout" itself. So the breakdown row for
          // activity_type_id 1 reads exactly "Run workout". The "type"
          // filter is resolved server-side against the canonical
          // ACTIVITY_NAME_TO_ID map (case-insensitive), so the repository
          // sends the canonical name ("Run") for the filter.
          final type = request.url.queryParameters['type'];
          final hasRun = type == null || type.toLowerCase() == 'run';
          final metrics = {
            'total_distance': hasRun ? 7050 : 0,
            'total_duration': hasRun ? 3143 : 0,
            'total_elevation_gain': hasRun ? 257 : 0,
            'activity_count': hasRun ? 1 : 0,
          };
          return http.Response(
            jsonEncode({
              ...metrics,
              'breakdown': [
                {
                  switch (period) {
                    StatisticsPeriod.week => 'day_of_week',
                    StatisticsPeriod.month => 'week_number',
                    StatisticsPeriod.year => 'month_number',
                  }: 1,
                  ...metrics,
                },
              ],
              'type_breakdown': [
                if (hasRun)
                  {
                    'activity_type_id': 1,
                    'activity_type': 'Run workout',
                    ...metrics,
                  },
              ],
            }),
            200,
          );
        });
        final date = DateTime(2026, 10, 20);
        final all = await repo.fetch(
          StatisticsQuery(period: period, date: date),
        );
        expect(all.totals.count, 1);
        final running = await repo.fetch(
          StatisticsQuery(period: period, date: date, sport: all.sports.single),
        );
        expect(running.totals.count, all.totals.count);
        expect(running.distanceMeters, 7050);
        expect(running.totals.durationSeconds, 3143);
        expect(running.totals.elevationMeters, 257);
        expect(running.buckets.single.metrics.count, 1);
      },
    );
  }
  // Keys are the exact v0.20.1 type_breakdown display names
  // (set_activity_name_based_on_activity_type: canonical name + " workout",
  // except "Workout"); values are the canonical names the server's
  // ACTIVITY_NAME_TO_ID filter lookup accepts.
  for (final names in {
    'Run': 'Run',
    'Trail run workout': 'Trail run',
    'Open water swim workout': 'Open water swim',
    'Strength training workout': 'Strength training',
    'Workout': 'Workout',
    'Workout workout': 'Workout',
  }.entries) {
    test('encodes sport name ${names.key} as ${names.value}', () async {
      final repo = repository((request) async {
        expect(request.url.queryParameters['type'], names.value);
        return http.Response(
          jsonEncode({
            'total_distance': 0,
            'total_duration': 0,
            'total_elevation_gain': 0,
            'activity_count': 0,
            'breakdown': <Object?>[],
            'type_breakdown': <Object?>[],
          }),
          200,
        );
      });
      await repo.fetch(
        StatisticsQuery(
          sport: StatisticsSport(
            id: 1,
            apiName: names.key,
            metrics: StatisticsMetrics.zero,
          ),
        ),
      );
    });
  }
  test('rejects late responses after account disconnect', () async {
    final response = Completer<http.Response>();
    final started = Completer<void>();
    final repo = repository((request) {
      started.complete();
      return response.future;
    });
    final pending = repo.fetch(StatisticsQuery());
    await started.future;
    await sessions.clear();
    response.complete(http.Response('{}', 200));
    await expectLater(
      pending,
      throwsA(
        isA<AppException>().having(
          (e) => e.code,
          'code',
          AppErrorCode.sessionExpired,
        ),
      ),
    );
  });
  test(
    'malformed aggregates fail instead of showing false zero totals',
    () async {
      final repo = repository(
        (request) async =>
            http.Response('{"breakdown":[],"type_breakdown":[]}', 200),
      );
      await expectLater(
        repo.fetch(StatisticsQuery()),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpectedResponseFormat,
          ),
        ),
      );
    },
  );
  test(
    'year and named sport filters are encoded and guest requests are refused',
    () async {
      var requests = 0;
      final repo = repository((request) async {
        requests++;
        expect(request.url.path, '/api/v1/activities/summaries');
        expect(request.url.queryParameters, {
          'period': 'year',
          'year': '2025',
          'type': 'Trail run',
        });
        return http.Response(
          jsonEncode({
            'total_distance': 0,
            'total_duration': 0,
            'total_elevation_gain': 0,
            'activity_count': 0,
            'breakdown': <Object?>[],
            'type_breakdown': <Object?>[],
          }),
          200,
        );
      });
      await repo.fetch(
        StatisticsQuery(
          period: StatisticsPeriod.year,
          date: DateTime(2025),
          sport: const StatisticsSport(
            id: 2,
            apiName: 'Trail run',
            metrics: StatisticsMetrics.zero,
          ),
        ),
      );
      await sessions.clear();
      await expectLater(
        repo.fetch(StatisticsQuery()),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.notAuthenticated,
          ),
        ),
      );
      expect(requests, 1);
    },
  );
}
