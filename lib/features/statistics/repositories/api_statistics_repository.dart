import 'package:endurain/features/statistics/repositories/statistics_response_adapter.dart';
import 'package:endurain/core/config/api_endpoints.dart';
import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/statistics_repository.dart';

class ApiStatisticsRepository implements StatisticsRepository {
  ApiStatisticsRepository({
    required ApiClient apiClient,
    required AuthSessionStore sessionStore,
    ApiEndpoints? endpoints,
  }) : _api = apiClient,
       _sessions = sessionStore,
       _endpoints = endpoints ?? ApiEndpoints.defaults;
  final ApiClient _api;
  final AuthSessionStore _sessions;
  final ApiEndpoints _endpoints;
  // v0.19.4 type_breakdown uses display names such as "Run workout".
  // Its type filter accepts canonical names such as "Run"; "Workout"
  // itself is already canonical and must remain intact.
  static String _sportFilterName(String name) =>
      name.trim().replaceFirst(RegExp(r' workout$', caseSensitive: false), '');

  @override
  Future<ActivityStatistics> fetch(StatisticsQuery query) async {
    final profile = await _sessions.getConnectionProfile();
    if (profile == null) {
      throw const AppException(AppErrorCode.notAuthenticated);
    }
    final date = query.date;
    final params = <String, String>{
      if (query.period == StatisticsPeriod.year)
        'year': '${date.year}'
      else
        'date':
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      if (query.sport != null) 'type': _sportFilterName(query.sport!.apiName),
    };
    final response = await _api.getJson(
      Uri(
        path: _endpoints.activitySummariesEndpoint(query.period.name),
        queryParameters: params,
      ).toString(),
      expectedOrigin: profile.origin,
      expectedProfileId: profile.id,
      failureCode: AppErrorCode.serverActivitiesFetchFailed,
    );
    final current = await _sessions.getConnectionProfile();
    if (current?.id != profile.id || current?.origin != profile.origin) {
      throw const AppException(AppErrorCode.sessionExpired);
    }
    return StatisticsResponseAdapter.decode(response, query.period);
  }
}
