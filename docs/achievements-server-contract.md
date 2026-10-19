# Achievements server data contract

Investigated 2026-10-19 against the clean local Endurain **v0.19.4** checkout,
commit `4eeb2cf47a88885155796f7c4dd7c9ec610913f5`, at
`/home/nilius/Documents/Codex/2026-10-18-ich-nutze-endurain-seit-einiger-zeit/endurain`.
Paths below are relative to that checkout. This is a source inspection, not a
verification of the user's deployed server. No credentials or live activities
were read. `GET /api/v1/about` exposes API `version` for a future runtime check;
a version string alone does not establish a stream's quality.

## Official records and source endpoints

`backend/app/core/routes.py` registers no achievements/personal-record resource.
The backend activity schemas and frontend source contain no personal-best or
best-effort feature. This establishes the absence in the inspected version,
not every future/custom deployment. Goals and period summaries exist but do not
provide fastest continuous distance efforts. Keep the local repository
replaceable; do not write invented records into unrelated server fields.

| Input | Authenticated GET | Contract |
| --- | --- | --- |
| Current owner/calendar | `/api/v1/profile` | Positive numeric `id`; `first_day_of_week` |
| Activity count | `/api/v1/activities/number` | Nonnegative integer; separate from list |
| Owner inventory | `/api/v1/activities/user/{id}/page_number/{page}/num_records/{size}` | Activity array or null; one-based pages |
| Activity detail | `/api/v1/activities/{id}` | Activity schema or null when absent/not visible; verify non-null identity |
| Raw GPS | `/api/v1/activities_streams/activity_id/{id}/stream_type/7` | Stream object or null; verify `activity_id` and `stream_type` |
| Other streams, if needed | `/api/v1/activities_streams/activity_id/{id}/all` | Stream array or null |
| Existing period statistics | `/api/v1/activities_summaries/{week\|month\|year}` | Aggregates for a requested period, not a lifetime record inventory |

Sources: `backend/app/activities/activity/{router,crud,schema}.py`,
`backend/app/activities/activity_streams/{router,schema,constants}.py`,
`backend/app/users/users_profile/router.py`, `backend/app/users/users/schema.py`,
`backend/app/core/router.py`. Existing Flutter endpoint/error/account behavior is
specified in [server-activities-api-contract.md](server-activities-api-contract.md).

## Summary semantics and provenance

Keep the exact positive integer `activity_type`; do not merge running, trail,
treadmill, road cycling, indoor cycling or e-bike variants. Unknown types may
still have summary records, but are ineligible for sport-specific distance targets.

`distance` and `elevation_gain` use metres; `total_elapsed_time` and
`total_timer_time` use seconds. Elapsed duration includes stops; timer duration
is the server's active-duration summary. Period duration should match Statistics
and use timer duration. Missing/invalid optional measurements are absent, not
zero; measured zero is preserved. Summary-derived longest distance, duration and
climbing records can exist without GPS. These are server-reported summaries,
not independently verified sensor measurements.

Use raw `start_time` as the absolute UTC instant (zone-less values are UTC).
`start_time_tz_applied` is display wall-clock text and must not replace UTC for
calendar bucketing. The current Flutter `ServerActivity.startTime` is derived
from the display-time model and can be absent even when raw `start_time` exists;
the achievements adapter must decode raw UTC independently. Missing absolute
start excludes yearly and period records, but need not exclude all-time summary
records. Week boundaries use `/profile.first_day_of_week`; month/year boundaries
use the server UTC calendar. See [statistics-api-contract.md](statistics-api-contract.md).

`created_at` is creation time, not a revision. The Activity API schema has no
`updated_at`, revision, checksum or stream ETag contract. Preserve a local
fingerprint of all calculation-relevant summary fields and calculation version.
A matching fingerprint cannot prove that GPS is unchanged.

## Distance efforts: an explicit server limitation

Supported stream types are 1 HR, 2 power, 3 cadence, 4 elevation, 5 speed,
6 pace, 7 map and 8 temperature. **There is no cumulative-distance stream or
pause/event stream in this version.** The schema accepts arbitrary waypoint
dictionaries, but that does not guarantee additional fields.

The inspected FIT, GPX, TCX and Strava importers produce map waypoints with
`time`, `lat`, `lon`. FIT source distance and timer events are not exposed as
per-point fields through this map stream. GPX import computes total distance
per original segment, but appends segment waypoints into one flat map list
without preserving boundary markers. Consequently:

- Compute effort distances from the complete raw timestamped GPS, never reduced
  chart data, average speed, summary distance or lap averages.
- Label these results as GPS-derived estimates. Do not scale GPS distance to
  force agreement with the summary distance.
- Validate finite coordinates/ranges and timestamps, preserving input order.
  Invalid samples, nonincreasing timestamps, implausible jumps and time gaps
  require a new continuous section. Thresholds belong to the versioned
  calculation policy; they are inferred discontinuities, not known pauses.
- Count ordinary stopped time inside a section. Never subtract elapsed stops,
  or concatenate sections to complete a target distance.
- The promise to reject every effort crossing an original explicit pause
  **cannot be guaranteed from these endpoints**. Even a short original GPX
  segment boundary may be irrecoverable. UI/documentation must disclose this
  limitation; no adapter may fabricate pause certainty.
- Missing/null GPS or unusable timestamps means distance efforts unavailable;
  summary records remain eligible. Transport failures remain retryable failures,
  not successful activities with no GPS.

Evidence: `backend/app/activities/activity_file_import/utils_gpx.py`
(`_process_trackpoint`, segment loop), `utils_tcx.py` (`_build_waypoints`),
`utils_fit.py` (map waypoint append), and `backend/app/strava/activity_utils.py`
(map waypoint construction). The existing Flutter `fetchRoute` retains timestamps
and invalid-coordinate section breaks, but does not validate time continuity or
infer pauses; the achievements adapter must apply its own full policy.

## Historical scan and reconciliation

List/count accept matching filters. Use an unfiltered owner inventory for
all-time records and bound page sizes to the Flutter adapter's 1–100 range.
The backend implements SQL offset/limit with `start_time` ordering and no
secondary ID ordering for that sort. There is no cursor/snapshot token or
modified-since query. Equal start times and concurrent changes can duplicate or
skip rows; unchanged counts do not prove an unchanged inventory.

Persist candidates and checkpoints by server origin plus connection/account ID.
Capture the active connection and pass `expectedOrigin`/`expectedProfileId` to
every request, rechecking after responses and before applying results. Account
switches clear rendered state and invalidate pending work.

Deduplicate IDs and persist work per activity. A resumable offset is only a hint:
restart inventory traversal from page one after interruption. Detect changed
counts, duplicate pages, inconsistent detail identities and unexpected page
shapes; do not mark those runs complete. An end-to-end inventory pass cannot
establish an atomic snapshot under arbitrary concurrent writes. Before pruning
an absent winner, refetch its detail: a successful JSON null is the v0.19.4
contract for an absent/not-visible activity (`router.py` response model
`Activity | None`, `crud.py` lookup returns `None`). A definitive HTTP 404 also
indicates absence. Either outcome may remove a previously owned, inventoried
activity; network,
authentication, forbidden or malformed errors must retain it. Stable repeated
inventory passes reduce risk but do not create a snapshot guarantee.

New backdated imports require full inventory traversal, not just scanning until
an already-seen start date. Recompute changed summaries. A user-triggered full
rebuild must refetch raw streams to discover edits invisible to summary
fingerprints. Replacing a failed scan must retain previous same-account bests
with incomplete/stale coverage, rather than deleting data on failure.

Coverage must separately record inventory traversal, successful summaries,
usable effort tracks, unsupported tracks and retryable failures. Until traversal
is complete show “Best found so far”; even completed traversal does not imply
every activity has an eligible GPS effort. Do not announce historical winners
as fresh record celebrations. No uploads or pending local recordings enter the
first release's rebuildable server inventory.

## Public adapter and engine boundary

Recommended server adapter outputs: owner scope/calendar; inventory page with
count; summary with exact sport/raw UTC start/SI measurements/fingerprint; raw
route with timed GPS and explicit availability/failure status. The adapter owns
API validation, account isolation and GPS-to-cumulative-distance conversion.
The pure engine receives ordered cumulative distance/time samples with section
IDs and provenance, plus nullable summary metrics. It owns candidate comparison,
interpolation, tie handling and calendar aggregation. Preserve original sample
indices/timestamps for later effort highlighting.

Approved public-seam tests should cover real ApiClient decoding of these endpoint
shapes, null versus failure, UTC versus display time, wrong stream identity,
late account responses, and loss of unusable samples without joining sections.
Engine and scanner tests belong at their separately approved public seams.
This documentation-only stage requires no new executable tests; final integration
runs repository formatting, analysis and the full test suite.
