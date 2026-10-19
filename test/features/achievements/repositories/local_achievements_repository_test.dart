import 'dart:io';

import 'package:endurain/features/achievements/models/achievement_models.dart';
import 'package:endurain/features/achievements/repositories/local_achievements_repository.dart';
import 'package:endurain/features/achievements/repositories/achievements_repository.dart';
import 'package:endurain/features/achievements/repositories/sqflite_achievement_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory directory;
  late LocalAchievementsRepository repository;
  LocalAchievementsRepository open() => LocalAchievementsRepository(
    store: SqfliteAchievementStore(
      databaseFactory: databaseFactoryFfiNoIsolate,
      databasePath: '${directory.path}/achievements.db',
    ),
  );
  setUp(() async {
    sqfliteFfiInit();
    directory = await Directory.systemTemp.createTemp('achievements_test_');
    repository = open();
  });
  tearDown(() async {
    await repository.close();
    await directory.delete(recursive: true);
  });

  test(
    'reopening preserves precise candidates and summary without raw tracks',
    () async {
      final date = DateTime.utc(2025, 1, 2, 10);
      await repository.replaceAnalysis(
        'account-a',
        AchievementAnalysis(
          activity: AchievementActivity(
            id: 42,
            sportType: 1,
            fingerprint: 'source-v1',
            startedAt: date,
            distanceMeters: 1234.5,
            samples: [AchievementSample(timestamp: date, distanceMeters: 0)],
          ),
          candidates: [
            AchievementCandidate(
              activityId: 42,
              sportType: 1,
              metric: AchievementMetric.fastestDistance,
              value: 234.56789,
              startedAt: date,
              targetDistanceMeters: 1000,
              effortStart: date.add(const Duration(microseconds: 12)),
              effortEnd: date.add(const Duration(seconds: 234)),
              distanceSource: AchievementDistanceSource.gps,
            ),
          ],
          calculationVersion: 1,
        ),
      );
      await repository.close();
      repository = open();
      final analyses = await repository.loadAnalyses('account-a');
      expect(analyses.single.activity.fingerprint, 'source-v1');
      expect(analyses.single.activity.samples, isEmpty);
      expect(analyses.single.candidates.single.value, 234.56789);
      expect(
        analyses.single.candidates.single.distanceSource,
        AchievementDistanceSource.gps,
      );
      expect(
        analyses.single.candidates.single.effortStart,
        date.add(const Duration(microseconds: 12)),
      );
      expect(await repository.loadAnalyses('account-b'), isEmpty);
    },
  );
  test(
    'analysis replacement and resumable coverage survive reopening together',
    () async {
      const initial = AchievementAnalysis(
        activity: AchievementActivity(id: 7, sportType: 1, fingerprint: 'old'),
        candidates: [],
        calculationVersion: 1,
      );
      await repository.replaceAnalysis('account-a', initial);
      await repository.replaceAnalysis(
        'account-a',
        const AchievementAnalysis(
          activity: AchievementActivity(
            id: 7,
            sportType: 1,
            fingerprint: 'new',
            distanceMeters: 3000,
          ),
          candidates: [],
          calculationVersion: 2,
        ),
        checkpoint: AchievementScanState(
          generation: 3,
          status: AchievementScanStatus.partial,
          inventoryIds: const [7, 8, 9],
          processedCount: 1,
          totalCount: 3,
          nextPage: 2,
          usableTrackCount: 1,
          unavailableTrackCount: 2,
          firstDayOfWeek: 0,
          failures: const {8: 'network'},
          skipped: const {
            9: ['missingGps'],
          },
          lastSuccessfulAt: DateTime.utc(2025, 1, 1),
          error: 'retry needed',
        ),
      );
      await repository.close();
      repository = open();
      final analyses = await repository.loadAnalyses('account-a');
      final state = (await repository.loadScanState('account-a'))!;
      expect(analyses.single.activity.fingerprint, 'new');
      expect(analyses.single.calculationVersion, 2);
      expect(state.generation, 3);
      expect(state.inventoryIds, [7, 8, 9]);
      expect(state.nextPage, 2);
      expect(state.firstDayOfWeek, 0);
      expect(state.failures, {8: 'network'});
      expect(state.skipped, {
        9: ['missingGps'],
      });
      expect(state.lastSuccessfulAt, DateTime.utc(2025, 1, 1));
      expect(state.error, 'retry needed');
      expect(await repository.loadScanState('account-b'), isNull);
    },
  );

  test(
    'cached records retain every contender and use saved calendar preference',
    () async {
      for (final entry in {10: 5000.0, 20: 8000.0}.entries) {
        await repository.replaceAnalysis(
          'account-a',
          AchievementAnalysis(
            activity: AchievementActivity(
              id: entry.key,
              sportType: 1,
              fingerprint: 'source',
              startedAt: DateTime.utc(2025, 1, 5),
              distanceMeters: entry.value,
            ),
            candidates: [
              AchievementCandidate(
                activityId: entry.key,
                sportType: 1,
                metric: AchievementMetric.longestDistance,
                value: entry.value,
                startedAt: DateTime.utc(2025, 1, 5),
              ),
            ],
            calculationVersion: 1,
          ),
        );
      }
      final noCalendar = await repository.load('account-a');
      expect(noCalendar.analyses, hasLength(2));
      expect(
        noCalendar.records
            .where((r) => r.winner.metric == AchievementMetric.longestDistance)
            .single
            .winner
            .activityId,
        20,
      );
      expect(
        noCalendar.records.where(
          (r) => r.winner.metric == AchievementMetric.weeklyDistance,
        ),
        isEmpty,
      );
      await repository.saveScanState(
        'account-a',
        const AchievementScanState(firstDayOfWeek: DateTime.sunday),
      );
      final calendar = await repository.load(
        'account-a',
        year: 2025,
        sportType: 1,
      );
      expect(
        calendar.records
            .where((r) => r.winner.metric == AchievementMetric.weeklyDistance)
            .single
            .winner
            .value,
        13000,
      );
      expect(
        (await repository.load('account-a', sportType: 4)).records,
        isEmpty,
      );
      expect((await repository.load('account-a', year: 2024)).records, isEmpty);
    },
  );

  test('failed refresh retains winner; only complete confirmed deletion promotes runner-up', () async {
    for (final entry in {1: 1000.0, 2: 2000.0}.entries) {
      await repository.replaceAnalysis(
        'account-a',
        AchievementAnalysis(
          activity: AchievementActivity(
            id: entry.key,
            sportType: 1,
            fingerprint: 'source',
          ),
          candidates: [
            AchievementCandidate(
              activityId: entry.key,
              sportType: 1,
              metric: AchievementMetric.longestDistance,
              value: entry.value,
              startedAt: null,
            ),
          ],
          calculationVersion: 1,
        ),
      );
    }
    await repository.saveScanState(
      'account-a',
      const AchievementScanState(
        status: AchievementScanStatus.failed,
        failures: {2: 'network'},
      ),
    );
    expect(
      (await repository.load('account-a')).records.single.winner.activityId,
      2,
    );
    await expectLater(
      repository.completeInventory(
        'account-a',
        confirmedDeletedIds: {2},
        state: const AchievementScanState(
          status: AchievementScanStatus.partial,
        ),
      ),
      throwsStateError,
    );
    expect(
      (await repository.load('account-a')).records.single.winner.activityId,
      2,
    );
    await repository.completeInventory(
      'account-a',
      confirmedDeletedIds: {2},
      state: const AchievementScanState(
        status: AchievementScanStatus.complete,
        inventoryIds: [1],
        processedCount: 1,
        totalCount: 1,
      ),
    );
    expect(
      (await repository.load('account-a')).records.single.winner.activityId,
      1,
    );
    expect(
      (await repository.loadScanState('account-a'))!.status,
      AchievementScanStatus.complete,
    );
  });

  test('rebuild clears one account without removing another account or its progress', () async {
    const analysis = AchievementAnalysis(
      activity: AchievementActivity(id: 1, sportType: 1, fingerprint: 'source'),
      candidates: [],
      calculationVersion: 1,
    );
    for (final scope in ['account-a', 'account-b']) {
      await repository.replaceAnalysis(
        scope,
        analysis,
        checkpoint: const AchievementScanState(generation: 4),
      );
    }
    await repository.clear('account-a');
    expect(await repository.loadAnalyses('account-a'), isEmpty);
    expect(await repository.loadScanState('account-a'), isNull);
    expect(await repository.loadAnalyses('account-b'), hasLength(1));
    expect((await repository.loadScanState('account-b'))!.generation, 4);
  });

  test(
    'incompatible calculation versions cannot compete with current records',
    () async {
      for (final entry in {1: 1, 2: 999}.entries) {
        await repository.replaceAnalysis(
          'account-a',
          AchievementAnalysis(
            activity: AchievementActivity(
              id: entry.key,
              sportType: 1,
              fingerprint: 'source',
            ),
            candidates: [
              AchievementCandidate(
                activityId: entry.key,
                sportType: 1,
                metric: AchievementMetric.longestDistance,
                value: entry.key * 1000,
                startedAt: null,
              ),
            ],
            calculationVersion: entry.value,
          ),
        );
      }
      final snapshot = await repository.load('account-a');
      expect(snapshot.outdatedCalculation, isTrue);
      expect(snapshot.analyses, hasLength(2));
      expect(snapshot.records.single.winner.activityId, 1);
    },
  );

  test(
    'invalid replacement leaves both prior result and checkpoint intact',
    () async {
      await repository.replaceAnalysis(
        'account-a',
        const AchievementAnalysis(
          activity: AchievementActivity(
            id: 1,
            sportType: 1,
            fingerprint: 'original',
          ),
          candidates: [],
          calculationVersion: 1,
        ),
        checkpoint: const AchievementScanState(processedCount: 1),
      );
      await expectLater(
        repository.replaceAnalysis(
          'account-a',
          const AchievementAnalysis(
            activity: AchievementActivity(
              id: 1,
              sportType: 1,
              fingerprint: 'invalid',
              distanceMeters: double.nan,
            ),
            candidates: [],
            calculationVersion: 1,
          ),
          checkpoint: const AchievementScanState(processedCount: 2),
        ),
        throwsArgumentError,
      );
      expect(
        (await repository.loadAnalyses('account-a'))
            .single
            .activity
            .fingerprint,
        'original',
      );
      expect((await repository.loadScanState('account-a'))!.processedCount, 1);
    },
  );
}
