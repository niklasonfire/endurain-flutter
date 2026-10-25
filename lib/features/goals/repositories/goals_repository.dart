import 'package:endurain/features/goals/models/goal_progress.dart';

/// Raw server payload source of the goals results, for cache-through
/// decorators (ADR-0001): the decorator fetches the envelope, stores it
/// raw, and re-parses it with ApiGoalsRepository when serving offline.
abstract interface class GoalsRawSource {
  /// Raw decoded JSON of `GET /api/v1/profile/goals/results`.
  /// The Endurain server answers JSON `null` when no goals remain.
  Future<Object?> fetchResultsEnvelope();
}

abstract interface class GoalsRepository {
  Future<List<GoalProgress>> fetchResults();
}
