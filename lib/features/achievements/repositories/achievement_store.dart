import 'package:endurain/features/achievements/models/achievement_models.dart';
import 'package:endurain/features/achievements/repositories/achievements_repository.dart';

/// Persistence boundary used by the local repository; never stores raw tracks.
abstract interface class AchievementStore {
  Future<List<AchievementAnalysis>> loadAnalyses(String scope);
  Future<AchievementScanState?> loadScanState(String scope);
  Future<void> replaceAnalysis(
    String scope,
    AchievementAnalysis analysis, {
    AchievementScanState? checkpoint,
  });
  Future<void> saveScanState(String scope, AchievementScanState state);
  Future<void> completeInventory(
    String scope, {
    required Set<int> confirmedDeletedIds,
    required AchievementScanState state,
  });
  Future<void> clear(String scope);
  Future<void> close();
}
