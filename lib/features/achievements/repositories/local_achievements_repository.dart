import 'dart:isolate';

import 'package:endurain/features/achievements/models/achievement_models.dart';
import 'package:endurain/features/achievements/services/achievement_calculator.dart';
import 'package:endurain/features/achievements/repositories/achievement_store.dart';
import 'package:endurain/features/achievements/repositories/achievements_repository.dart';
import 'package:endurain/features/achievements/repositories/sqflite_achievement_store.dart';

class LocalAchievementsRepository implements AchievementsRepository {
  LocalAchievementsRepository({AchievementStore? store})
    : _store = store ?? SqfliteAchievementStore();
  final AchievementStore _store;
  @override
  Future<List<AchievementAnalysis>> loadAnalyses(String scope) =>
      _store.loadAnalyses(scope);
  @override
  Future<AchievementScanState?> loadScanState(String scope) =>
      _store.loadScanState(scope);
  @override
  Future<void> replaceAnalysis(
    String scope,
    AchievementAnalysis analysis, {
    AchievementScanState? checkpoint,
  }) => _store.replaceAnalysis(scope, analysis, checkpoint: checkpoint);
  @override
  Future<void> saveScanState(String scope, AchievementScanState state) =>
      _store.saveScanState(scope, state);
  @override
  Future<void> completeInventory(
    String scope, {
    required Set<int> confirmedDeletedIds,
    required AchievementScanState state,
  }) => _store.completeInventory(
    scope,
    confirmedDeletedIds: confirmedDeletedIds,
    state: state,
  );
  @override
  Future<void> clear(String scope) => _store.clear(scope);
  @override
  Future<void> close() => _store.close();
  @override
  Future<AchievementSnapshot> load(
    String scope, {
    int? year,
    int? sportType,
    int? firstDayOfWeek,
  }) async {
    final analyses = await _store.loadAnalyses(scope);
    final state = await _store.loadScanState(scope);
    final calendar = firstDayOfWeek ?? state?.firstDayOfWeek;
    final records = await Isolate.run(
      () => _calculateRecords(analyses, year, sportType, calendar),
    );
    return AchievementSnapshot(
      analyses: analyses,
      records: List.unmodifiable(records),
      scanState: state,
      outdatedCalculation: analyses.any(
        (a) => a.calculationVersion != AchievementCalculator.calculationVersion,
      ),
    );
  }
}

/// Keep isolate input independent of the repository and its native SQLite handle.
List<AchievementRecord> _calculateRecords(
  List<AchievementAnalysis> analyses,
  int? year,
  int? sportType,
  int? firstDayOfWeek,
) {
  return const AchievementCalculator().selectRecords(
    analyses,
    year: year,
    sportType: sportType,
    firstDayOfWeek: firstDayOfWeek,
  );
}
