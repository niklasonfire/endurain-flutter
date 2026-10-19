import 'package:endurain/features/achievements/models/achievement_models.dart';

enum AchievementScanStatus { idle, scanning, partial, complete, failed }

/// Durable progress for one account. Inventory and stream coverage are separate.
class AchievementScanState {
  const AchievementScanState({
    this.generation = 0,
    this.rebuildInProgress = false,
    this.pendingRebuildIds = const [],
    this.status = AchievementScanStatus.idle,
    this.inventoryIds = const [],
    this.processedCount = 0,
    this.totalCount = 0,
    this.usableTrackCount = 0,
    this.unavailableTrackCount = 0,
    this.failures = const {},
    this.skipped = const {},
    this.nextPage = 1,
    this.firstDayOfWeek,
    this.lastSuccessfulAt,
    this.error,
  });
  final int generation;
  final bool rebuildInProgress;
  final List<int> pendingRebuildIds;
  final AchievementScanStatus status;
  final List<int> inventoryIds;
  final int processedCount;
  final int totalCount;
  final int usableTrackCount;
  final int unavailableTrackCount;
  final Map<int, String> failures;
  final Map<int, List<String>> skipped;
  final int nextPage;
  final int? firstDayOfWeek;
  final DateTime? lastSuccessfulAt;
  final String? error;
}

class AchievementSnapshot {
  const AchievementSnapshot({
    required this.analyses,
    required this.records,
    required this.scanState,
    required this.outdatedCalculation,
  });
  final List<AchievementAnalysis> analyses;
  final List<AchievementRecord> records;
  final AchievementScanState? scanState;

  /// Old results remain available as analyses, but never compete with current ones.
  final bool outdatedCalculation;
}

/// Replaceable boundary for locally derived or future official server records.
abstract interface class AchievementsRepository {
  Future<AchievementSnapshot> load(
    String scope, {
    int? year,
    int? sportType,
    int? firstDayOfWeek,
  });
  Future<List<AchievementAnalysis>> loadAnalyses(String scope);
  Future<AchievementScanState?> loadScanState(String scope);
  Future<void> replaceAnalysis(
    String scope,
    AchievementAnalysis analysis, {
    AchievementScanState? checkpoint,
  });
  Future<void> saveScanState(String scope, AchievementScanState state);

  /// Only IDs independently confirmed deleted after a stable, complete inventory.
  Future<void> completeInventory(
    String scope, {
    required Set<int> confirmedDeletedIds,
    required AchievementScanState state,
  });
  Future<void> clear(String scope);
  Future<void> close();
}
