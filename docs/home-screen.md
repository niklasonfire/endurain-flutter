# Home screen

Home is the first tab. It presents a large current-week summary, Endurain goal
progress, and the three latest activities. Activities, Statistics, and Settings
remain separate tabs. The activity cards open the existing detail screens;
“All activities” selects the Activities tab.

## Recording

“Record Activity” occupies a separate, fixed layout region above the tab bar.
Only the dashboard content scrolls. The action remains available during loading,
empty states, and request failures without covering the final activity card.
An active, paused, or recoverable recording changes the action to return to that
recording. The recording map is constructed only when this action is pressed.
Home itself must not initialize the map or request location permission.

The app-lifetime `ActivityRecordingController` belongs to `AppServices`.
`App.initState` starts `recoverActiveRecording()` before any recording screen is
opened. A concurrent `start()` awaits this recovery, preventing a quick tap from
replacing a persisted session. The native recorder determines the recovered
state; the Geolocator fallback safely restores a formerly recording session as
paused. Leaving the map disposes its view controllers, not the recording
controller. The map provides a back action to Home; native/system back works too.

## Data contracts

* The weekly summary uses `GET /api/v1/activities/summaries?period=week` with a
  `YYYY-MM-DD` date. The server defines the weekly boundary. UTC dates match the
  existing Statistics feature. Day bars represent duration in one accent color:
  the endpoint does not provide sport-specific daily segments.
* Goals use `GET /api/v1/profile/goals/results`. Server-computed progress and
  periods are authoritative. At most three goals appear on Home, weekly goals
  first. The first version displays existing goals; goal editing remains in
  Endurain. Goal time and statistics time retain their existing server meanings.
* Latest activities use the existing server activities repository, descending by
  start time, with three results. Routes load separately via the existing route
  endpoint; an activity without GPS has a sport illustration instead.
* Guest mode summarizes guest-owned local records and displays local detail
  screens. Records belonging to a previous account are excluded. Guest mode has
  no server goals. Authenticated pending uploads are indicated separately and do
  not increase server totals before upload completes.

`HomeController` loads sections independently and rejects responses from an old
connection or refresh generation. Connection changes immediately remove the
previous account's displayed data. Existing data survives an update failure for
the same connection. Home refreshes on first opening, pull-to-refresh, successful
recording upload, upload-queue completion, and returning from the recording map.
App resume refreshes stale data (five minutes or a UTC date change).

## Verification

Public behavior tests cover startup recovery without opening a map, a quick
start during that recovery preserving the durable session, and Home navigation
to Activities and back on Material and Cupertino. Home widget tests cover the
fixed action while dashboard content scrolls, empty/error states, and recording
status. Data tests cover independent requests, account changes, and local guest
summaries. Existing recording-controller tests exercise recovery, pause/resume,
completion, and durable persistence. Run the full Flutter suite and analyzer
before committing; native process-death behavior still needs a real iOS/Android
device check.
