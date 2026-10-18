import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';

class ApiServerActivitiesRepository implements ServerActivitiesRepository {
  ApiServerActivitiesRepository({
    required ApiClient apiClient,
    required AuthSessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final ApiClient _apiClient;
  final AuthSessionStore _sessionStore;
  static const _activities = '/api/v1/activities';

  Future<ConnectionProfile> _connection() async {
    final profile = await _sessionStore.getConnectionProfile();
    if (profile == null) {
      throw const AppException(AppErrorCode.notAuthenticated);
    }
    return profile;
  }

  Future<void> _checkConnection(ConnectionProfile expected) async {
    final current = await _sessionStore.getConnectionProfile();
    if (current?.id != expected.id || current?.origin != expected.origin) {
      throw const AppException(AppErrorCode.sessionExpired);
    }
  }

  Future<Object?> _get(String endpoint, ConnectionProfile profile) async {
    try {
      final result = await _apiClient.getJson(
        endpoint,
        failureCode: AppErrorCode.serverActivitiesFetchFailed,
        expectedOrigin: profile.origin,
        expectedProfileId: profile.id,
      );
      // ApiClient checks before a request/refresh. Also guard late HTTP 200
      // responses here; those must never cross an account switch.
      await _checkConnection(profile);
      return result;
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException(
        AppErrorCode.serverActivitiesFetchFailed,
        cause: error,
      );
    }
  }

  @override
  Future<ServerActivityPage> fetchPage({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  }) async {
    if (page < 1 || pageSize < 1 || pageSize > 100) {
      throw ArgumentError('Page must be positive; page size must be 1–100.');
    }
    if (query.activityType != null && query.activityType! < 1) {
      throw ArgumentError('Activity type must be positive.');
    }
    if (query.startDate != null &&
        query.endDate != null &&
        _date(query.startDate!).compareTo(_date(query.endDate!)) > 0) {
      throw ArgumentError('Start date must precede end date.');
    }
    final profile = await _connection();
    // accountId can be a UUID; /profile is the source of the numeric user id
    // required by the activity endpoint. Never infer it from credentials.
    final user = _object(await _get('/api/v1/profile', profile));
    final userId = _positiveInt(user['id']);
    final filters = <String, String>{
      if (query.search.trim().isNotEmpty) 'name_search': query.search.trim(),
      if (query.activityType != null) 'type': '${query.activityType}',
      if (query.startDate != null) 'start_date': _date(query.startDate!),
      if (query.endDate != null) 'end_date': _date(query.endDate!),
    };
    final count = await _get(
      _endpoint('$_activities/number', filters),
      profile,
    );
    if (count is! int || count < 0) _invalid();
    final rows = await _get(
      _endpoint(
        '$_activities/user/$userId/page_number/$page/num_records/$pageSize',
        {...filters, 'sort_by': 'start_time', 'sort_order': 'desc'},
      ),
      profile,
    );
    if (rows != null && rows is! List) _invalid();
    return ServerActivityPage(
      items: rows == null ? [] : (rows as List).map(_activity).toList(),
      page: page,
      pageSize: pageSize,
      total: count,
    );
  }

  @override
  Future<List<int>> fetchActivityTypes() async {
    final profile = await _connection();
    final result = await _get('$_activities/types', profile);
    if (result == null) return const [];
    final types = _object(result).keys.map((key) => _positiveInt(key)).toList()
      ..sort();
    return List.unmodifiable(types);
  }

  @override
  Future<ServerActivity> fetchDetail(int activityId) async {
    _validateId(activityId);
    final profile = await _connection();
    final result = _activity(await _get('$_activities/$activityId', profile));
    if (result.id != activityId) _invalid();
    return result;
  }

  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) async {
    _validateId(activityId);
    final profile = await _connection();
    final stream = await _get(
      '/api/v1/activities_streams/activity_id/$activityId/stream_type/7',
      profile,
    );
    if (stream == null) return const [];
    final data = _object(stream);
    if (data['stream_type'] != 7 || data['activity_id'] != activityId) {
      _invalid();
    }
    final points = data['stream_waypoints'];
    if (points is! List) _invalid();
    final route = <ServerRoutePoint>[];
    for (final point in points) {
      if (point is! Map) continue;
      final lat = _number(point['lat']);
      final lon = _number(point['lon']);
      if (lat != null &&
          lon != null &&
          lat >= -90 &&
          lat <= 90 &&
          lon >= -180 &&
          lon <= 180) {
        route.add(ServerRoutePoint(latitude: lat, longitude: lon));
      }
    }
    return List.unmodifiable(route);
  }

  static ServerActivity _activity(Object? value) {
    final data = _object(value);
    return ServerActivity(
      id: _positiveInt(data['id']),
      name: _text(data['name']) ?? '',
      activityType: _positiveInt(data['activity_type']),
      startTime: _timestamp(data['start_time']),
      distanceMeters: _number(data['distance']),
      elapsedSeconds: _number(data['total_elapsed_time']),
      timerSeconds: _number(data['total_timer_time']),
      elevationGainMeters: _number(data['elevation_gain']),
      averageHeartRate: _number(data['average_hr']),
      averageSpeedMetersPerSecond: _number(data['average_speed']),
      averagePower: _number(data['average_power']),
      calories: _number(data['calories']),
      description: _text(data['description']),
      city: _text(data['city']),
      town: _text(data['town']),
      country: _text(data['country']),
    );
  }

  static Map<String, Object?> _object(Object? value) {
    if (value is! Map<String, dynamic>) _invalid();
    return value;
  }

  static int _positiveInt(Object? value) {
    final parsed = value is int
        ? value
        : value is String
        ? int.tryParse(value)
        : null;
    if (parsed == null || parsed < 1) _invalid();
    return parsed;
  }

  static String? _text(Object? value) => value is String ? value : null;
  static double? _number(Object? value) =>
      value is num && value.isFinite ? value.toDouble() : null;
  static DateTime? _timestamp(Object? value) {
    if (value is! String || value.isEmpty) return null;
    // Server UTC timestamps may omit an explicit offset. Treat them as UTC,
    // independent of the device timezone, before the UI localizes the value.
    final normalized =
        RegExp(r'(Z|[+-]\d{2}:?\d{2})$', caseSensitive: false).hasMatch(value)
        ? value
        : '${value}Z';
    return DateTime.tryParse(normalized)?.toUtc();
  }

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  static String _endpoint(String path, Map<String, String> query) =>
      Uri(path: path, queryParameters: query.isEmpty ? null : query).toString();
  static void _validateId(int id) {
    if (id < 1) throw ArgumentError.value(id, 'activityId');
  }

  static Never _invalid() =>
      throw const AppException(AppErrorCode.unexpectedResponseFormat);
}
