import 'package:endurain/core/config/api_endpoints.dart';
import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/features/goals/models/goal_progress.dart';
import 'package:endurain/features/goals/repositories/goals_repository.dart';

class ApiGoalsRepository implements GoalsRepository {
  ApiGoalsRepository({
    required ApiClient apiClient,
    required AuthSessionStore sessionStore,
    ApiEndpoints? endpoints,
  }) : _api = apiClient,
       _sessions = sessionStore,
       _endpoints = endpoints ?? ApiEndpoints.defaults;
  final ApiClient _api;
  final AuthSessionStore _sessions;
  final ApiEndpoints _endpoints;
  @override
  Future<List<GoalProgress>> fetchResults() async {
    final profile = await _sessions.getConnectionProfile();
    if (profile == null) {
      throw const AppException(AppErrorCode.notAuthenticated);
    }
    final response = await _api.getJson(
      _endpoints.profileGoalsResultsEndpoint,
      expectedOrigin: profile.origin,
      expectedProfileId: profile.id,
      failureCode: AppErrorCode.serverActivitiesFetchFailed,
    );
    final current = await _sessions.getConnectionProfile();
    if (current?.id != profile.id || current?.origin != profile.origin) {
      throw const AppException(AppErrorCode.sessionExpired);
    }
    // Endurain returns JSON null when the user has no remaining goals.
    if (response == null) return const [];
    if (response is! List) _invalid();
    return List.unmodifiable(response.map(_decode));
  }

  static GoalProgress _decode(Object? row) {
    if (row is! Map<String, dynamic>) _invalid();
    final id = row['goal_id'];
    final interval = row['interval'];
    final sport = row['activity_type'];
    final type = row['goal_type'];
    if (id is! int ||
        id < 1 ||
        !{'daily', 'weekly', 'monthly', 'yearly'}.contains(interval) ||
        !{
          'run',
          'bike',
          'swim',
          'walk',
          'strength',
          'cardio',
        }.contains(sport) ||
        !{
          'calories',
          'activities',
          'distance',
          'elevation',
          'duration',
        }.contains(type)) {
      _invalid();
    }
    final field = type == 'activities' ? 'activities_number' : type;
    return GoalProgress(
      id: id,
      interval: interval as String,
      activityType: sport as String,
      goalType: type as String,
      startDate: _date(row['start_date']),
      endDate: _date(row['end_date']),
      achieved: _number(row['total_$field']),
      target: _number(row['goal_$field']),
      percentage: _number(row['percentage_completed']),
    );
  }

  static DateTime _date(Object? value) {
    if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      _invalid();
    }
    final date = DateTime.tryParse('${value}T00:00:00Z');
    if (date == null || date.toIso8601String().substring(0, 10) != value) {
      _invalid();
    }
    return date;
  }

  static double _number(Object? value) {
    if (value is! num || !value.isFinite || value < 0) _invalid();
    return value.toDouble();
  }

  static Never _invalid() =>
      throw const AppException(AppErrorCode.unexpectedResponseFormat);
}
