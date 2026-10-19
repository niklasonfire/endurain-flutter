/// Values retain Endurain's SI units. Duration goals use elapsed seconds,
/// whereas the weekly statistics use timer seconds.
class GoalProgress {
  const GoalProgress({
    required this.id,
    required this.interval,
    required this.activityType,
    required this.goalType,
    required this.startDate,
    required this.endDate,
    required this.achieved,
    required this.target,
    required this.percentage,
  });
  final int id;
  final String interval;
  final String activityType;
  final String goalType;
  final DateTime startDate;
  final DateTime endDate;
  final double achieved;
  final double target;
  final double percentage;
  double get progress => (percentage / 100).clamp(0, 1);
  bool get isAchieved => target > 0 && percentage >= 100;
}
