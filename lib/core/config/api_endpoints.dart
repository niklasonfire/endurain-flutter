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

  /// Paginated activities of one user; `page_number` and `num_records`
  /// travel as query parameters and the total comes from the response
  /// envelope.
  String activityListEndpoint(int userId) =>
      '$_base/activities/users/$userId';
  String activityDetailEndpoint(int activityId) =>
      '$_base/activities/$activityId';

  /// GPS route stream (`stream_type` 7) of one activity.
  String activityRouteStreamEndpoint(int activityId) =>
      '$_base/activities/$activityId/streams/7';

  /// Every recorded stream of one activity.
  String activityStreamsEndpoint(int activityId) =>
      '$_base/activities/$activityId/streams';

  /// Every recorded lap of one activity.
  String activityLapsEndpoint(int activityId) =>
      '$_base/activities/$activityId/laps';

  // Statistics endpoints
  String activitySummariesEndpoint(String period) =>
      '$_base/activities_summaries/$period';

  // Goals endpoints
  String get profileGoalsResultsEndpoint => '$_base/profile/goals/results';
}
