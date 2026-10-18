# Local server activities verification

## Scope and reference

Review baseline: `8f35231` (original app). Server reference: local Endurain v0.19.4 source. Specification source: the user's approved task and implementation plan, restated here for an auditable local review:

- Install a separately identified and locally signed Android app alongside the original.
- Add a tab for the connected user's server activities, newest first, with pagination, pull refresh, search, sport and calendar date filters, using the web activity list as a visual reference.
- Provide detail descriptions and available metrics, and a zoomable GPS map with start/end markers using the configured tile provider. Detail and route failures are independent; activities without GPS remain useful.
- Keep the repository replaceable, reuse existing authentication, and discard visible data and late responses after logout, account or server changes.
- Server activity features are read-only. Editing, deletion, charts, laps and permanent offline caching are outside scope.
- Keep all work local. Do not submit issues, PRs, uploads or tests against private user services.

The implementation, TDD and code-review instructions in `.agents/skills/` were read. The approved repository/controller/widget seams are used for behavioral verification. The two review axes are reported separately; no additional review subagents were started under the task's explicit delegation limit.

## Verification status

Verified on Linux with the isolated Flutter 3.47.3 / Dart 3.13.3 toolchain and `XDG_CONFIG_HOME` from `LOCAL_BUILD_STATUS.md`, after list/detail commits were complete:

| Check | Result |
| --- | --- |
| `flutter test --coverage --reporter expanded` | 1,495 passed, 1 skipped; one complete run, 4m15s |
| `flutter analyze` | No issues |
| `dart format --output=none --set-exit-if-changed .` | 443 files, 0 changes |
| `git diff --check` | Clean |
| CI coverage gate, exact `.github/workflows/ci.yml` exclusions | 90.52% (8,884/9,814 lines, 196 files); 80% total and 60% per-file thresholds passed |

The skipped test is the existing Apple-only test in `test/shared/adaptive/adaptive_list_section_test.dart:67`, intentionally excluded on Linux. New server activity files range from 71.1% line coverage (list screen) to 100%; repository 97.4%, list controller 97.6%, detail controller 98.1%, detail screen 91.9%, route map 100%.

Focused repository verification: 10 tests passed. Added regressions prove guest methods issue no HTTP calls, logout while counting prevents the subsequent page request, and a mismatched GPS stream activity is rejected. The segment regression added during detail implementation verifies that valid samples after missing/invalid GPS begin a new polyline segment. Existing targeted list/detail runs were followed by the single integrated suite above.

Local command logs for this session: `/tmp/endurain-flutter-full-test.log`, `/tmp/endurain-flutter-analyze.log`, `/tmp/endurain-flutter-format.log`, `/tmp/endurain-flutter-coverage.log`. These ephemeral files contain synthetic test output and are not an archived test service.

## Standards review

Sources: `CONTRIBUTING.md`, `.github/workflows/ci.yml`, existing architecture guard tests and adjacent repository/controller/widget patterns. Review command: `git diff 8f35231...HEAD`; feature commits are `bab5ecf`, `5e3e841`, `27f1599`, `51013ef` (Android handoff documentation `ba94b39`).

No remaining documented-standard violations or material baseline code smells found in the reviewed feature. Networking/JSON remain behind `ServerActivitiesRepository`; widgets do not use concrete persistence stores. Controllers use `SafeNotifier`, release their connection listeners and reject disposed/stale work. The local-only scope overrides upstream issue/PR publication workflow; no upstream contribution is being submitted.

## Spec review

- Numeric user identity is resolved through authenticated `/api/v1/profile`, independently of a UUID account identifier. Count/types are scoped by the server token. Count and page receive matching encoded filters; list order is explicitly newest first.
- New repository operations use GET and the existing `ApiClient` for credentials, refresh, origin/profile checks and transport policy. There are no new edit/delete/upload paths or permanent server activity caches.
- Repository checks reject late responses after a connection switch; list generations additionally reject stale searches/pages, and active connection notifications clear visible list/detail data. Detail destinations stay invalidated after a switch rather than reusing the same activity ID under another account. Guest repository calls do not contact the server.
- SI values remain distinct from missing data and measured zero. UTC timestamps are localized for display; date filters preserve selected calendar dates against server UTC dates. Existing unit preferences feed sport-specific distance, speed and pace formatting (including swim/rowing/nautical units).
- Route loading is separate from metadata. A route failure preserves metadata and can retry alone. Without any loaded metadata/initial summary, a metadata error shows the retry state. Indoor/no-GPS activities show their metadata and an explicit no-route state.
- Real Flutter Map rendering uses configured tiles, fit-to-route bounds, drag/pinch zoom, and start/finish markers. Invalid/missing GPS samples now mark a segment boundary: the reviewed parser originally joined valid samples across a gap; the regression test failed before the `startsSegment` model/parser change and passes afterward.

No remaining blocking feature-spec findings identified. The visual review is a source/widget comparison with web list conventions, not a screenshot comparison on a physical device.

## Limits

- All HTTP tests use synthetic injected transport; no private server or user data was contacted. Existing shared-client tests cover token refresh, account binding and supported HTTP/HTTPS policy. This is not a live login/SSO or server integration test.
- Widget tests cover English/German, a dark list and wide detail layout. New text is translated for German/English; other catalogues use English fallback text. No claim is made about native accessibility, real touch gestures or every locale/device layout.
- Map tests render 12,000 samples, repeated coordinates and invalid/gapped samples using test tile URLs. This checks safe rendering and map configuration, not on-device frame rate, real tile availability or unbounded track size.
- The timestamp parser uses Dart's ISO date parser, which normalizes impossible calendar-day values rather than rejecting every such malformed timestamp. The typed v0.19.4 server emits valid datetimes; this small out-of-contract malformed-input limitation was explicitly left unchanged by the implementation lead.
- Count and page requests are separate server snapshots; concurrent edits by another client can change pagination results. Duplicate IDs are removed in the list.
- Android APK construction, signature/manifest checks and native Kotlin tests are recorded separately in the Android handoff. Installation beside the original app, callback routing with both apps installed and device smoke tests remain device checks until actually performed.

Review result: Standards — 0 remaining material findings. Spec — 0 remaining blocking findings.
