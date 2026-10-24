# Server activities API contract

Reference: local Endurain v0.19.4 backend, `backend/app/activities/activity/{router,schema,crud}.py`, `backend/app/activities/activity_streams/{router,schema}.py`, and `backend/app/users/users_profile/router.py`.

The UI consumes `ServerActivitiesRepository` through `AppServices.serverActivities`. JSON decoding, endpoint paths, token handling and numeric server user IDs stay behind this boundary. The repository only performs GET requests. Local recordings and uploads use their existing repositories.

| Operation | Authenticated GET | Response |
| --- | --- | --- |
| Resolve numeric user | `/api/v1/profile` | Object with positive integer `id` |
| List | `/api/v1/activities/user/{user_id}/page_number/{page}/num_records/{size}` | Activity array, or null for no rows |
| Filtered count | `/api/v1/activities/number` | Nonnegative integer |
| Available sports | `/api/v1/activities/types` | Object mapping numeric type ID strings to sport names, or null |
| Detail | `/api/v1/activities/{id}` | Activity object |
| GPS | `/api/v1/activities_streams/activity_id/{id}/stream_type/7` | Stream object, or null when there is no GPS stream |

List and count use the same encoded query parameters: `name_search` (trimmed, omitted if empty), `type`, `start_date`, `end_date`. Dates use `YYYY-MM-DD`, inclusive against the server's UTC `start_time` date (`func.date(Activity.start_time)`), without converting the selected calendar day using the device timezone. List additionally sends `sort_by=start_time&sort_order=desc`. Pages are one-based, default size 20. The app adapter accepts sizes 1–100. Total and page are separate requests and therefore are not an atomic snapshot if another client changes server data while loading.

`/profile.id` is resolved for each list request, because stored authentication `accountId` can be a UUID and is not the numeric activity user ID. `ApiClient` supplies the bearer token and existing refresh/retry behavior. Each operation captures the active profile, passes `expectedOrigin` and `expectedProfileId` to every request, then rechecks the profile after each completed response. A late HTTP 200 for another account is rejected with `sessionExpired`. Nothing is cached across accounts. UI controllers must clear already rendered data when `AuthSessionStore.connectionChanges` emits a different connection; repository checks alone cannot clear widgets.

Activity `id` and `activity_type` must be positive integers. Unknown additional fields are ignored. Optional missing, null or incompatible metrics stay null; measured zero stays zero. Mapping uses meters (`distance`, `elevation_gain`), seconds (`total_elapsed_time`, `total_timer_time`), meters/second (`average_speed`), bpm (`average_hr`), watts (`average_power`) and kcal (`calories`). Description and location fields are optional. UTC `start_time` strings without an explicit zone are interpreted as UTC; explicit offsets are converted to UTC, and malformed dates stay absent. v0.20.1 activities additionally carry `timezone`, the recording location's IANA zone name: the app renders absolute start times in that zone (DST rules included, via a bundled pure-Dart database), falling back to device-local display when the field is missing or unknown; offset-free wall clock values stay unconverted.

GPS is loaded only by `fetchRoute`, never during listing or `fetchDetail`. Stream type 7 is the map stream, with `stream_waypoints` objects containing `lat` and `lon`. Only finite numeric coordinates inside latitude ±90 / longitude ±180 are returned, in server order. Missing or invalid coordinates are skipped and the next valid point has `startsSegment: true`, so the map never connects a line across missing GPS samples; `(0,0)` remains valid. Null stream means an empty route. Wrong stream/activity identity or a malformed stream envelope is an `unexpectedResponseFormat` error. The v0.19.4 typed endpoint directly returns the required stream, so loading all streams is unnecessary.

Repository failures remain `AppException`: existing authentication, refresh and timeout codes are preserved; HTTP and transport load failures use `serverActivitiesFetchFailed`; malformed required response fields use `unexpectedResponseFormat`. Public methods reject invalid positive IDs, page sizes and reversed date ranges before making a request.

Contract tests: `test/features/server_activities/server_activities_repository_test.dart`. They use real `ApiClient` and `AuthSessionStore` with an injected HTTP transport to verify paths, credentials, URL encoding, filter/count parity, nullable values, dates, GPS and late-response isolation. Existing `test/core/services/api_client_json_test.dart` covers token refresh; final app verification is a separate implementation step.
