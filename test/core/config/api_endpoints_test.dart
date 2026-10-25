import 'package:flutter_test/flutter_test.dart';
import 'package:endurain/core/config/api_endpoints.dart';
import 'package:endurain/core/config/app_config.dart';

void main() {
  group('ApiEndpoints', () {
    group('default /api/v1 base', () {
      const endpoints = ApiEndpoints();

      test('tokenEndpoint', () {
        expect(endpoints.tokenEndpoint, '/api/v1/auth/login');
      });

      test('mfaVerifyEndpoint', () {
        expect(endpoints.mfaVerifyEndpoint, '/api/v1/auth/mfa/verify');
      });

      test('refreshEndpoint', () {
        expect(endpoints.refreshEndpoint, '/api/v1/auth/refresh');
      });

      test('logoutEndpoint', () {
        expect(endpoints.logoutEndpoint, '/api/v1/auth/logout');
      });

      test('idpListEndpoint', () {
        expect(endpoints.idpListEndpoint, '/api/v1/public/idp');
      });

      test('idpLoginEndpoint', () {
        expect(endpoints.idpLoginEndpoint, '/api/v1/public/idp/login');
      });

      test('idpSessionTokenExchangeEndpoint', () {
        expect(
          endpoints.idpSessionTokenExchangeEndpoint,
          '/api/v1/public/idp/session',
        );
      });

      test('serverSettingsEndpoint', () {
        expect(
          endpoints.serverSettingsEndpoint,
          '/api/v1/public/server_settings',
        );
      });

      test('activityUploadEndpoint', () {
        expect(endpoints.activityUploadEndpoint, '/api/v1/activities/upload');
      });

      test('activityIngestionJobEndpoint encodes the job id', () {
        expect(
          endpoints.activityIngestionJobEndpoint('a b/1'),
          '/api/v1/activities/ingestion-jobs/a%20b%2F1',
        );
      });

      test('profileEndpoint', () {
        expect(endpoints.profileEndpoint, '/api/v1/profile');
      });

      test('activityTypesEndpoint', () {
        expect(endpoints.activityTypesEndpoint, '/api/v1/activities/types');
      });

      test('activityListEndpoint', () {
        expect(
          endpoints.activityListEndpoint(42),
          '/api/v1/activities/users/42',
        );
      });

      test('activityDetailEndpoint', () {
        expect(endpoints.activityDetailEndpoint(7), '/api/v1/activities/7');
      });

      test('activityRouteStreamEndpoint', () {
        expect(
          endpoints.activityRouteStreamEndpoint(7),
          '/api/v1/activities/7/streams/7',
        );
      });

      test('activityStreamsEndpoint', () {
        expect(
          endpoints.activityStreamsEndpoint(7),
          '/api/v1/activities/7/streams',
        );
      });

      test('activityLapsEndpoint', () {
        expect(endpoints.activityLapsEndpoint(7), '/api/v1/activities/7/laps');
      });

      test('activitySummariesEndpoint', () {
        expect(
          endpoints.activitySummariesEndpoint,
          '/api/v1/activities/summaries',
        );
      });

      test('profileGoalsResultsEndpoint', () {
        expect(
          endpoints.profileGoalsResultsEndpoint,
          '/api/v1/profile/goals/results',
        );
      });
    });

    group('custom /api/v2 base', () {
      const v2 = ApiEndpoints(AppConfig(apiBasePath: '/api/v2'));

      test('tokenEndpoint uses v2 base', () {
        expect(v2.tokenEndpoint, '/api/v2/auth/login');
      });

      test('serverSettingsEndpoint uses v2 base', () {
        expect(v2.serverSettingsEndpoint, '/api/v2/public/server_settings');
      });

      test('activityUploadEndpoint uses v2 base', () {
        expect(v2.activityUploadEndpoint, '/api/v2/activities/upload');
      });

      test('activityIngestionJobEndpoint uses v2 base', () {
        expect(
          v2.activityIngestionJobEndpoint('job-1'),
          '/api/v2/activities/ingestion-jobs/job-1',
        );
      });

      test('profileEndpoint uses v2 base', () {
        expect(v2.profileEndpoint, '/api/v2/profile');
      });

      test('mfaVerifyEndpoint uses v2 base', () {
        expect(v2.mfaVerifyEndpoint, '/api/v2/auth/mfa/verify');
      });

      test('refreshEndpoint uses v2 base', () {
        expect(v2.refreshEndpoint, '/api/v2/auth/refresh');
      });

      test('logoutEndpoint uses v2 base', () {
        expect(v2.logoutEndpoint, '/api/v2/auth/logout');
      });

      test('idpListEndpoint uses v2 base', () {
        expect(v2.idpListEndpoint, '/api/v2/public/idp');
      });

      test('idpLoginEndpoint uses v2 base', () {
        expect(v2.idpLoginEndpoint, '/api/v2/public/idp/login');
      });

      test('idpSessionTokenExchangeEndpoint uses v2 base', () {
        expect(
          v2.idpSessionTokenExchangeEndpoint,
          '/api/v2/public/idp/session',
        );
      });

      test('activityTypesEndpoint uses v2 base', () {
        expect(v2.activityTypesEndpoint, '/api/v2/activities/types');
      });

      test('activityListEndpoint uses v2 base', () {
        expect(v2.activityListEndpoint(42), '/api/v2/activities/users/42');
      });

      test('activityDetailEndpoint uses v2 base', () {
        expect(v2.activityDetailEndpoint(7), '/api/v2/activities/7');
      });

      test('activityRouteStreamEndpoint uses v2 base', () {
        expect(
          v2.activityRouteStreamEndpoint(7),
          '/api/v2/activities/7/streams/7',
        );
      });

      test('activityStreamsEndpoint uses v2 base', () {
        expect(v2.activityStreamsEndpoint(7), '/api/v2/activities/7/streams');
      });

      test('activityLapsEndpoint uses v2 base', () {
        expect(v2.activityLapsEndpoint(7), '/api/v2/activities/7/laps');
      });

      test('activitySummariesEndpoint uses v2 base', () {
        expect(v2.activitySummariesEndpoint, '/api/v2/activities/summaries');
      });

      test('profileGoalsResultsEndpoint uses v2 base', () {
        expect(v2.profileGoalsResultsEndpoint, '/api/v2/profile/goals/results');
      });
    });
  });
}
