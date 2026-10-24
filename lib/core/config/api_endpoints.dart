import 'package:endurain/core/config/app_config.dart';

/// Builds API endpoint paths from [AppConfig.apiBasePath].
///
/// All path getters replace the hard-coded `/api/v1` prefix with
/// [AppConfig.apiBasePath], so a future API version bump or multi-environment
/// deployment only requires changing [AppConfig.apiBasePath] in one place.
///
/// Header names, timeouts, and multipart field names remain in
/// `ApiConstants`.
class ApiEndpoints {
  const ApiEndpoints([this._config = AppConfig.defaults]);

  /// Shared instance for the default [AppConfig]. Tests and call sites that do
  /// not need a custom base path can reuse this instead of allocating one.
  static const ApiEndpoints defaults = ApiEndpoints();

  final AppConfig _config;

  String get _base => _config.apiBasePath;

  // Authentication endpoints
  String get tokenEndpoint => '$_base/auth/login';
  String get mfaVerifyEndpoint => '$_base/auth/mfa/verify';
  String get refreshEndpoint => '$_base/auth/refresh';
  String get logoutEndpoint => '$_base/auth/logout';

  // SSO/OAuth endpoints
  String get idpListEndpoint => '$_base/public/idp';
  String get idpLoginEndpoint => '$_base/public/idp/login';
  String get idpSessionTokenExchangeEndpoint => '$_base/public/idp/session';

  // Authenticated profile endpoint.
  String get profileEndpoint => '$_base/profile';

  // Server settings public endpoint
  String get serverSettingsEndpoint => '$_base/public/server_settings';

  // Activity endpoints
  String get activityUploadEndpoint => '$_base/activities/upload';

  /// Status of a background ingestion job created by an upload (`202`).
  String activityIngestionJobEndpoint(String jobId) =>
      '$_base/activities/ingestion-jobs/${Uri.encodeComponent(jobId)}';

  // Activity browsing endpoints
  String get activityTypesEndpoint => '$_base/activities/types';
  String get activityCountEndpoint => '$_base/activities/number';
  String activityPageEndpoint(int userId, int page, int pageSize) =>
      '$_base/activities/user/$userId/page_number/$page/num_records/$pageSize';
  String activityDetailEndpoint(int activityId) =>
      '$_base/activities/$activityId';

  /// GPS route stream (`stream_type` 7) of one activity.
  String activityRouteStreamEndpoint(int activityId) =>
      '$_base/activities_streams/activity_id/$activityId/stream_type/7';

  /// Every recorded stream of one activity.
  String activityStreamsEndpoint(int activityId) =>
      '$_base/activities_streams/activity_id/$activityId/all';

  /// Every recorded lap of one activity.
  String activityLapsEndpoint(int activityId) =>
      '$_base/activities_laps/activity_id/$activityId/all';

  // Statistics endpoints
  /// Activity summaries for one period. v0.20.1 moved the period from the
  /// path into a `period` query parameter on a single summaries resource.
  String get activitySummariesEndpoint => '$_base/activities/summaries';

  // Goals endpoints
  String get profileGoalsResultsEndpoint => '$_base/profile/goals/results';
}
