import 'dart:convert';
import 'dart:isolate';

import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/models/auth_session.dart';
import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/auth_session_store.dart';

import 'package:endurain/features/achievements/models/achievement_models.dart';
import 'package:endurain/features/activity/services/geo_distance.dart';
import 'package:endurain/features/achievements/services/achievement_calculator.dart';

class AchievementOwner {
  const AchievementOwner(this.userId, this.firstDayOfWeek);
  final int userId;
  final int? firstDayOfWeek;
}

class AchievementTrack {
  const AchievementTrack(this.activity, this.reasons);
  final AchievementActivity activity;
  final List<String> reasons;
}

abstract interface class AchievementServerSource {
  Future<AchievementOwner> fetchOwner(AuthSession session);
  Future<int> fetchCount(AuthSession session);
  Future<List<AchievementActivity>> fetchPage(
    AuthSession session, {
    required int userId,
    required int page,
    int pageSize = 100,
  });
  Future<AchievementTrack> fetchTrack(
    AuthSession session,
    AchievementActivity activity,
  );

  /// Verified server absence: HTTP 404 or the v0.19.4 detail-null contract.
  Future<bool> isDeleted(AuthSession session, int activityId);
}

class ApiAchievementServerSource implements AchievementServerSource {
  ApiAchievementServerSource({
    required ApiClient apiClient,
    required AuthSessionStore sessionStore,
  }) : _api = apiClient,
       _sessions = sessionStore;
  final ApiClient _api;
  final AuthSessionStore _sessions;
  static const gapSeconds = 60;
  // Conservative GPS quality guards, versioned with the calculation policy.
  static const runningMaxMetersPerSecond = 15.0;
  static const cyclingMaxMetersPerSecond = 45.0;

  Future<void> _check(AuthSession expected) async {
    if ((await _sessions.readSession())?.profileId != expected.profileId) {
      throw const AppException(AppErrorCode.notAuthenticated);
    }
  }

  Future<Object?> _get(AuthSession session, String path) async {
    await _check(session);
    final value = await _api.getJson(
      path,
      failureCode: AppErrorCode.serverActivitiesFetchFailed,
      expectedOrigin: session.origin,
      expectedProfileId: session.profileId,
    );
    await _check(session);
    return value;
  }

  static Never _invalid() =>
      throw const AppException(AppErrorCode.unexpectedResponseFormat);
  static Map<String, dynamic> _object(Object? value) =>
      value is Map<String, dynamic> ? value : _invalid();
  static int _id(Object? value) =>
      value is int && value > 0 ? value : _invalid();
  static double? _number(Object? value) =>
      value is num && value.isFinite && value >= 0 ? value.toDouble() : null;
  static DateTime? _utc(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    if (text.isEmpty) return null;
    final zoned = RegExp(
      r'(Z|[+-]\d\d:?\d\d)$',
      caseSensitive: false,
    ).hasMatch(text);
    return DateTime.tryParse(zoned ? text : '${text}Z')?.toUtc();
  }

  @override
  Future<AchievementOwner> fetchOwner(AuthSession session) async {
    final data = _object(await _get(session, '/api/v1/profile'));
    final id = _id(data['id']);
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final day = days.indexOf(data['first_day_of_week']?.toString() ?? '');
    return AchievementOwner(id, day < 0 ? null : day + 1);
  }

  @override
  Future<int> fetchCount(AuthSession session) async {
    final data = await _get(session, '/api/v1/activities/number');
    return data is int && data >= 0 ? data : _invalid();
  }

  @override
  Future<List<AchievementActivity>> fetchPage(
    AuthSession session, {
    required int userId,
    required int page,
    int pageSize = 100,
  }) async {
    if (page < 1 || pageSize < 1 || pageSize > 100 || userId < 1) {
      throw ArgumentError('Invalid inventory page');
    }
    final data = await _get(
      session,
      '/api/v1/activities/user/$userId/page_number/$page/num_records/$pageSize?sort_by=start_time&sort_order=desc',
    );
    if (data == null) return const [];
    if (data is! List) _invalid();
    return data
        .map((row) {
          final json = _object(row);
          final id = _id(json['id']);
          final sport = _id(json['activity_type']);
          final start = _utc(json['start_time']);
          final distance = _number(json['distance']);
          final timer = _number(json['total_timer_time']);
          final gain = _number(json['elevation_gain']);
          return AchievementActivity(
            id: id,
            sportType: sport,
            startedAt: start,
            distanceMeters: distance,
            durationSeconds: timer,
            elevationGainMeters: gain,
            fingerprint: jsonEncode([
              id,
              sport,
              start?.toIso8601String(),
              distance,
              timer,
              gain,
            ]),
            distanceSource: AchievementDistanceSource.gps,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<bool> isDeleted(AuthSession session, int activityId) async {
    await _check(session);
    final result = await _api.getJsonResource(
      '/api/v1/activities/$activityId',
      failureCode: AppErrorCode.serverActivitiesFetchFailed,
      expectedOrigin: session.origin,
      expectedProfileId: session.profileId,
    );
    await _check(session);
    if (!result.found || result.value == null) return true;
    if (_id(_object(result.value)['id']) != activityId) _invalid();
    return false;
  }

  @override
  Future<AchievementTrack> fetchTrack(
    AuthSession session,
    AchievementActivity activity,
  ) async {
    if (AchievementCalculator.distancesForSport(activity.sportType).isEmpty) {
      return AchievementTrack(activity, const ['sportHasNoDistanceEfforts']);
    }
    final data = await _get(
      session,
      '/api/v1/activities_streams/activity_id/${activity.id}/stream_type/7',
    );
    if (data == null) {
      return AchievementTrack(activity, const ['gpsUnavailable']);
    }
    final stream = _object(data);
    if (stream['activity_id'] != activity.id ||
        stream['stream_type'] != 7 ||
        stream['stream_waypoints'] is! List) {
      _invalid();
    }
    final result = await Isolate.run(() => _decodeTrack(activity, stream));
    await _check(session);
    return result;
  }

  static AchievementTrack _decodeTrack(
    AchievementActivity activity,
    Map<String, dynamic> stream,
  ) {
    final samples = <AchievementSample>[];
    final reasons = <String>{};
    var segment = 0;
    var distance = 0.0;
    DateTime? previousTime;
    double? previousLat, previousLon;
    final maxSpeed = AchievementCalculator.isRunning(activity.sportType)
        ? runningMaxMetersPerSecond
        : cyclingMaxMetersPerSecond;
    for (final point in stream['stream_waypoints'] as List) {
      final time = point is Map ? _utc(point['time']) : null;
      final lat = point is Map ? _coordinate(point['lat'], 90) : null;
      final lon = point is Map ? _coordinate(point['lon'], 180) : null;
      if (time == null || lat == null || lon == null) {
        reasons.add('invalidGpsPoint');
        segment++;
        previousTime = null;
        distance = 0;
        continue;
      }
      if (previousTime != null) {
        final seconds = time.difference(previousTime).inMicroseconds / 1000000;
        final step = geoDistanceMeters(previousLat!, previousLon!, lat, lon);
        if (seconds <= 0 || seconds > gapSeconds || step / seconds > maxSpeed) {
          reasons.add(
            seconds <= 0
                ? 'unorderedGpsTime'
                : seconds > gapSeconds
                ? 'gpsGap'
                : 'gpsJump',
          );
          segment++;
          distance = 0;
        } else {
          distance += step;
        }
      }
      samples.add(
        AchievementSample(
          timestamp: time,
          distanceMeters: distance,
          segmentId: segment,
        ),
      );
      previousTime = time;
      previousLat = lat;
      previousLon = lon;
    }
    if (samples.length < 2) reasons.add('gpsUnavailable');
    if (!samples.any((sample) => sample.distanceMeters > 0)) {
      reasons.add('gpsNoContinuousTravel');
    }
    return AchievementTrack(
      AchievementActivity(
        id: activity.id,
        sportType: activity.sportType,
        fingerprint: activity.fingerprint,
        startedAt: activity.startedAt,
        distanceMeters: activity.distanceMeters,
        durationSeconds: activity.durationSeconds,
        elevationGainMeters: activity.elevationGainMeters,
        samples: samples,
        distanceSource: AchievementDistanceSource.gps,
      ),
      reasons.toList(),
    );
  }

  static double? _coordinate(Object? value, int limit) =>
      value is num && value.isFinite && value.abs() <= limit
      ? value.toDouble()
      : null;
}
