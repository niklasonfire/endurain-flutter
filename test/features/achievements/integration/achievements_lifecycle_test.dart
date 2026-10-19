import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/base_http_client.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/features/achievements/controllers/achievements_controller.dart';
import 'package:endurain/features/achievements/models/achievement_models.dart';
import 'package:endurain/features/achievements/repositories/achievements_repository.dart';
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

  test('GPS bests survive restart, rebuild from raw edits, and promote after deletion', () async {
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
    final directory = await Directory.systemTemp.createTemp(
      'achievement-lifecycle-',
    );
    addTearDown(() => directory.delete(recursive: true));
    var rawRequests = 0;
    var secondsPerPoint = 10;
    var secondActivitySeconds = 15;
    Completer<http.Response>? blockedTrack;
    Completer<void>? trackReached;
    var deleted = false;
    final start = DateTime.utc(2026, 10, 1);
    Map<String, Object> summary(int id) => {
      'id': id,
      'activity_type': 1,
      'distance': 1500,
      'total_timer_time': 200,
      'start_time': start.toIso8601String(),
    };
    final api = ApiClient(
      sessionStore: sessions,
      baseClient: BaseHttpClient(
        httpClient: MockClient((request) async {
          final path = request.url.path;
          Object? payload;
          if (path.endsWith('/profile')) {
            payload = {'id': 42, 'first_day_of_week': 'monday'};
          } else if (path.endsWith('/number')) {
            payload = deleted ? 1 : 2;
          } else if (path.contains('/page_number/')) {
            payload = [if (!deleted) summary(1), summary(2)];
          } else if (path.contains('/activities_streams/')) {
            rawRequests++;
            final id = path.contains('/activity_id/1/') ? 1 : 2;
            if (id == 2 && blockedTrack != null) {
              trackReached!.complete();
              return blockedTrack.future;
            }
            payload = {
              'activity_id': id,
              'stream_type': 7,
              'stream_waypoints': [
                for (var i = 0; i <= 12; i++)
                  {
                    'lat': 0,
                    'lon': i * 0.001,
                    'time': start
                        .add(
                          Duration(
                            seconds:
                                i *
                                (id == 1
                                    ? secondsPerPoint
                                    : secondActivitySeconds),
                          ),
                        )
                        .toIso8601String(),
                  },
              ],
            };
          }
          return http.Response(jsonEncode(payload), 200);
        }),
      ),
    );
    late LocalAchievementsRepository repository;
    late AchievementScanService scanner;
    late AchievementsController controller;
    void open() {
      repository = LocalAchievementsRepository(
        store: SqfliteAchievementStore(
          databaseFactory: databaseFactoryFfi,
          databasePath: '${directory.path}/achievements.sqlite',
        ),
      );
      scanner = AchievementScanService(
        repository: repository,
        source: ApiAchievementServerSource(
          apiClient: api,
          sessionStore: sessions,
        ),
        sessionStore: sessions,
      );
      controller = AchievementsController(scanService: scanner);
    }

    Future<void> close() async {
      controller.dispose();
      scanner.dispose();
      await repository.close();
    }

    open();
    addTearDown(() => close());
    AchievementCandidate kilometre() => controller.records
        .singleWhere(
          (record) =>
              record.winner.metric == AchievementMetric.fastestDistance &&
              record.winner.targetDistanceMeters == 1000,
        )
        .winner;

    await controller.initialize();
    await controller.refresh();
    expect(controller.scanState!.status, AchievementScanStatus.complete);
    expect(kilometre().activityId, 1);
    expect(kilometre().distanceSource, AchievementDistanceSource.gps);
    // Independent equatorial geodesic reference: 0.001 degrees = 111.31949 m.
    expect(kilometre().value, closeTo(89.8315, 0.001));
    expect(kilometre().effortStart, isNotNull);
    expect(kilometre().effortEnd, isNotNull);
    final persisted = kilometre();
    expect(rawRequests, 2);

    await close();
    open();
    await controller.initialize();
    expect(kilometre().value, persisted.value);
    expect(kilometre().effortStart, persisted.effortStart);
    expect(kilometre().effortEnd, persisted.effortEnd);
    expect(kilometre().distanceSource, AchievementDistanceSource.gps);
    expect(controller.scanState!.usableTrackCount, 2);
    expect(
      rawRequests,
      2,
      reason: 'Reading the durable cache needs no network',
    );

    secondsPerPoint = 12;
    await controller.refresh();
    expect(
      rawRequests,
      2,
      reason: 'Matching metadata reuses cached raw analysis',
    );
    expect(kilometre().value, persisted.value);
    await controller.rebuild();
    expect(rawRequests, 4);
    expect(kilometre().value, closeTo(107.7978, 0.001));

    // Interrupt a second rebuild after activity 1 is committed. Remaining raw
    // work must survive a process/database restart despite identical summaries.
    secondActivitySeconds = 20;
    blockedTrack = Completer<http.Response>();
    trackReached = Completer<void>();
    final interrupted = controller.rebuild();
    await trackReached.future;
    await scanner.cancel();
    blockedTrack.complete(http.Response('null', 200));
    await interrupted;
    blockedTrack = null;
    await close();
    open();
    await controller.initialize();
    expect(controller.scanState!.rebuildInProgress, isTrue);
    expect(controller.scanState!.pendingRebuildIds, contains(2));
    await controller.refresh();
    expect(controller.scanState!.rebuildInProgress, isFalse);
    expect(controller.scanState!.status, AchievementScanStatus.complete);
    final secondKilometre = controller.snapshot!.analyses
        .singleWhere((analysis) => analysis.activity.id == 2)
        .candidates
        .singleWhere(
          (candidate) =>
              candidate.metric == AchievementMetric.fastestDistance &&
              candidate.targetDistanceMeters == 1000,
        );
    expect(secondKilometre.value, closeTo(179.6631, 0.001));

    deleted = true;
    await controller.refresh();
    expect(controller.scanState!.status, AchievementScanStatus.complete);
    expect(kilometre().activityId, 2);
    expect(kilometre().value, closeTo(179.6631, 0.001));
    expect(controller.snapshot!.analyses.map((a) => a.activity.id), [2]);
  });
}
