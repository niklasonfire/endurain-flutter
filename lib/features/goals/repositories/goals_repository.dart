import 'package:endurain/features/goals/models/goal_progress.dart';

abstract interface class GoalsRepository {
  Future<List<GoalProgress>> fetchResults();
}
