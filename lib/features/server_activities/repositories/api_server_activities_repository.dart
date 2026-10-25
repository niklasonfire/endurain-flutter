import 'package:endurain/features/server_activities/models/server_activity_start_time.dart';
import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:endurain/features/server_activities/repositories/server_activity_graph_repository.dart';
import 'package:endurain/core/config/api_endpoints.dart';
import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_page.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';

/// Server activity fetches that expose their raw decoded JSON envelopes so an
/// offline read-cache decorator can store a payload exactly as the server
/// returned it and re-parse it through the same helpers as a live fetch
/// (ADR-0001, decision D1).
abstract interface class ServerActivitiesRawSource
    implements ServerActivitiesRepository, ServerActivityGraphRepository {
  /// Decoded activity-list envelope (`{'items': [...], 'total': int}`) exactly
  /// as returned by the server.
  Future<Object?> fetchActivityListEnvelope({
    ServerActivityQuery query = const ServerActivityQuery(),
    int page = 1,
    int pageSize = 20,
  });

  /// Decoded activity-types object exactly as returned by the server; its
  /// keys are the type ids.
  Future<Object?> fetchActivityTypesEnvelope();

  /// Decoded activity-detail object exactly as returned by the server.
  Future<Object?> fetchDetailEnvelope(int activityId);

  /// Decoded route-stream object exactly as returned by the server, or
  /// `null` when the server answered 404 (the no-route state).
  Future<Object?> fetchRouteStreamEnvelope(int activityId);

  /// Decoded activity streams envelope (`{'items': [...]}`) exactly as
  /// returned by the server for the activity's graphs.
  Future<Object?> fetchActivityStreamsEnvelope(int activityId);

  /// Decoded activity laps envelope (`{'items': [...]}`) exactly as returned
  /// by the server.
  Future<Object?> fetchActivityLapsEnvelope(int activityId);
}

class ApiServerActivitiesRepository implements ServerActivitiesRawSource {
  ApiServerActivitiesRepository({
    required ApiClient apiClient,
    required AuthSessionStore sessionStore,
    ApiEndpoints? endpoints,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore,
       _endpoints = endpoints ?? ApiEndpoints.defaults;

  final ApiClient _apiClient;
  final AuthSessionStore _sessionStore;
  final ApiEndpoints _endpoints;

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
    final envelope = await fetchActivityListEnvelope(
      query: query,
      page: page,
      pageSize: pageSize,
    );
    return parseActivityListEnvelope(
      envelope: envelope,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<Object?> fetchActivityListEnvelope({
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
    final user = _object(await _get(_endpoints.profileEndpoint, profile));
    final userId = _positiveInt(user['id']);
    // One paginated request carries both the rows and the matching total in
    // its response envelope, so list and count are an atomic snapshot.
    return _get(
      _endpoint(
        _endpoints.activityListEndpoint(userId),
        activityListQueryParameters(
          query: query,
          page: page,
          pageSize: pageSize,
        ),
      ),
      profile,
    );
  }

  /// Parses a decoded activity-list envelope (live or cached) into a
  /// [ServerActivityPage]; see [ServerActivitiesRawSource].
  static ServerActivityPage parseActivityListEnvelope({
    required Object? envelope,
    required int page,
    required int pageSize,
  }) {
    final map = _object(envelope);
    final rows = map['items'];
    final count = map['total'];
    if (rows is! List || count is! int || count < 0) _invalid();
    return ServerActivityPage(
      items: rows.map(_activity).toList(),
      page: page,
      pageSize: pageSize,
      total: count,
    );
  }

  /// Query parameters of the activity-list request. Shared with the offline
  /// read cache so a cache key canonicalizes the exact request a live fetch
  /// performs (decision D2).
  static Map<String, String> activityListQueryParameters({
    required ServerActivityQuery query,
    required int page,
    required int pageSize,
  }) => <String, String>{
    if (query.search.trim().isNotEmpty) 'name': query.search.trim(),
    if (query.activityType != null) 'type': '${query.activityType}',
    if (query.startDate != null) 'start_date': _date(query.startDate!),
    if (query.endDate != null) 'end_date': _date(query.endDate!),
    'page_number': '$page',
    'num_records': '$pageSize',
    'sort_by': 'start_time',
    'sort_order': 'desc',
  };

  @override
  Future<List<int>> fetchActivityTypes() async =>
      parseActivityTypesEnvelope(await fetchActivityTypesEnvelope());

  @override
  Future<Object?> fetchActivityTypesEnvelope() async {
    final profile = await _connection();
    return _get(_endpoints.activityTypesEndpoint, profile);
  }

  /// Parses a decoded activity-types object (live or cached) into the sorted
  /// type ids; see [ServerActivitiesRawSource].
  static List<int> parseActivityTypesEnvelope(Object? envelope) {
    if (envelope == null) return const [];
    final types = _object(
      envelope,
    ).keys.map((key) => _positiveInt(key)).toList()..sort();
    return List.unmodifiable(types);
  }

  @override
  Future<ServerActivity> fetchDetail(int activityId) async =>
      parseDetailEnvelope(
        envelope: await fetchDetailEnvelope(activityId),
        activityId: activityId,
      );

  @override
  Future<Object?> fetchDetailEnvelope(int activityId) async {
    _validateId(activityId);
    final profile = await _connection();
    return _get(_endpoints.activityDetailEndpoint(activityId), profile);
  }

  /// Parses a decoded activity-detail object (live or cached) into a
  /// [ServerActivity]; see [ServerActivitiesRawSource].
  static ServerActivity parseDetailEnvelope({
    required Object? envelope,
    required int activityId,
  }) {
    final result = _activity(envelope);
    if (result.id != activityId) _invalid();
    return result;
  }

  @override
  Future<List<ServerRoutePoint>> fetchRoute(int activityId) async =>
      parseRouteStreamEnvelope(
        envelope: await fetchRouteStreamEnvelope(activityId),
        activityId: activityId,
      );

  @override
  Future<Object?> fetchRouteStreamEnvelope(int activityId) async {
    _validateId(activityId);
    final profile = await _connection();
    // A missing GPS stream answers 404; that is the no-route state, not a
    // load failure.
    try {
      return await _get(
        _endpoints.activityRouteStreamEndpoint(activityId),
        profile,
      );
    } on AppException catch (error) {
      if (error.statusCode != 404 ||
          error.code != AppErrorCode.serverActivitiesFetchFailed) {
        rethrow;
      }
      return null;
    }
  }

  /// Parses a decoded route-stream object (live or cached) into the route;
  /// a `null` envelope is the cached no-route state and parses to an empty
  /// route. See [ServerActivitiesRawSource].
  static List<ServerRoutePoint> parseRouteStreamEnvelope({
    required Object? envelope,
    required int activityId,
  }) {
    if (envelope == null) return const [];
    final data = _object(envelope);
    if (data['stream_type'] != 7 || data['activity_id'] != activityId) {
      _invalid();
    }
    final points = data['stream_waypoints'];
    if (points is! List) _invalid();
    final route = <ServerRoutePoint>[];
    var startsSegment = false;
    for (final point in points) {
      if (point is! Map) {
        startsSegment = true;
        continue;
      }
      final lat = _number(point['lat']);
      final lon = _number(point['lon']);
      if (lat != null &&
          lon != null &&
          lat >= -90 &&
          lat <= 90 &&
          lon >= -180 &&
          lon <= 180) {
        route.add(
          ServerRoutePoint(
            latitude: lat,
            longitude: lon,
            time: _timestamp(point['time']),
            startsSegment: startsSegment,
          ),
        );
        startsSegment = false;
      } else {
        startsSegment = true;
      }
    }
    return List.unmodifiable(route);
  }

  @override
  Future<List<ServerActivityGraph>> fetchGraphs(int activityId) async =>
      parseGraphsEnvelope(
        envelope: await fetchActivityStreamsEnvelope(activityId),
        activityId: activityId,
      );

  @override
  Future<Object?> fetchActivityStreamsEnvelope(int activityId) =>
      _detailEnvelope(
        _endpoints.activityStreamsEndpoint(activityId),
        activityId,
      );

  /// Parses a decoded streams envelope (live or cached) into the activity's
  /// graphs; see [ServerActivitiesRawSource].
  static List<ServerActivityGraph> parseGraphsEnvelope({
    required Object? envelope,
    required int activityId,
  }) {
    final graphs = <ServerActivityGraph>[];
    for (final row in _detailRowsFromEnvelope(envelope, activityId)) {
      if (!ServerGraphMetric.values.any(
        (metric) => metric.streamType == row['stream_type'],
      )) {
        continue;
      }
      if (row['stream_waypoints'] is! List) _invalid();
      final graph = ServerActivityGraph.fromJson(row);
      if (graph.hasValues) graphs.add(graph);
    }
    return List.unmodifiable(graphs);
  }

  @override
  Future<List<ServerActivityLap>> fetchLaps(int activityId) async =>
      parseLapsEnvelope(
        envelope: await fetchActivityLapsEnvelope(activityId),
        activityId: activityId,
      );

  /// Query parameters every detail child-collection (streams, laps) request
  /// uses. Shared with the offline read cache so a cache key canonicalizes
  /// the exact request a live fetch performs (decision D2).
  static const Map<String, String> detailRowsQueryParameters = {
    'page_number': '1',
    'num_records': '200',
  };

  @override
  Future<Object?> fetchActivityLapsEnvelope(int activityId) =>
      _detailEnvelope(_endpoints.activityLapsEndpoint(activityId), activityId);

  /// Parses a decoded laps envelope (live or cached) into the activity's
  /// laps; see [ServerActivitiesRawSource].
  static List<ServerActivityLap> parseLapsEnvelope({
    required Object? envelope,
    required int activityId,
  }) => List.unmodifiable(
    _detailRowsFromEnvelope(
      envelope,
      activityId,
    ).map(ServerActivityLap.fromJson),
  );

  Future<Object?> _detailEnvelope(String endpoint, int activityId) async {
    _validateId(activityId);
    final profile = await _connection();
    // Child collections are paginated; one maximum-size page covers every
    // stream type and lap of a single activity.
    return _get(_endpoint(endpoint, detailRowsQueryParameters), profile);
  }

  static List<Map<String, dynamic>> _detailRowsFromEnvelope(
    Object? envelope,
    int activityId,
  ) {
    final result = _object(envelope)['items'];
    if (result is! List) _invalid();
    return result.map((value) {
      final row = _object(value);
      if (row['activity_id'] != activityId) _invalid();
      return row;
    }).toList();
  }

  static ServerActivity _activity(Object? value) {
    final data = _object(value);
    // A masked raw start time must not be revealed by the parallel display field.
    final displayStartTime = data['start_time'] == null
        ? null
        : ServerActivityStartTime.fromApi(
            timezoneApplied: data['start_time_tz_applied'],
            fallback: data['start_time'],
            timezone: data['timezone'],
          );
    return ServerActivity(
      id: _positiveInt(data['id']),
      name: _text(data['name']) ?? '',
      activityType: _positiveInt(data['activity_type']),
      startTime: displayStartTime?.instantUtc,
      displayStartTime: displayStartTime,
      distanceMeters: _number(data['distance']),
      elapsedSeconds: _number(data['total_elapsed_time']),
      timerSeconds: _number(data['total_timer_time']),
      elevationGainMeters: _number(data['elevation_gain']),
      averageHeartRate: _number(data['average_hr']),
      averageSpeedMetersPerSecond: _number(data['average_speed']),
      paceSecondsPerMeter: _number(data['pace']),
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
