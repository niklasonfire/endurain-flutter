# Local graphs and statistics verification

## Scope, baseline and reference

Review baseline: `71980db1e48582547e2b0efc681926854abb39ff` (clean at review start). The specification is the user's approved local feature request and subsequent clarifications: graphs for server activities (pace, heart rate and available metrics), a statistics tab with immediately visible weekly distance and sport breakdown, and an updateable Android APK. Server reference remains the local Endurain v0.19.4 source; no backend update or upstream rebase is part of this work.

Graph axes must use recorded time or explicitly label the measurement-index fallback. Pace wire values are seconds/metre, converted using the existing sport and unit preferences. Rounds use server lap records, without inventing kilometre splits. Mixed-sport statistics exclude non-distance sports from the distance total and use complete server aggregates rather than the visible activity page. Session switches must clear visible data and reject late work; operations remain GET-only. Version 0.10.0+17 retains the existing local Android identity and signing key.

The implementation, TDD and code-review skill instructions were read. The approved public seams are the replaceable API/repository module, controllers, formatters, graph data and statistics metrics. Both review axes are performed independently within this review task, without extra agents under the explicit delegation limit. The user's local-only scope overrides the upstream contribution issue/PR workflow.

Standards sources: `CONTRIBUTING.md`, `.github/copilot-instructions.md`, `.github/instructions/endurain-scalable-mobile.instructions.md`, `.github/workflows/ci.yml`, architecture guards and adjacent feature patterns. Review command: `git diff 71980db1e48582547e2b0efc681926854abb39ff...HEAD`.

## Verification status

Feature commits: `4794eba` (statistics), `fa5720e` (graphs/laps), `1649714` (finite reciprocal guard). Independent rendering regression: `40f63dc`. Integrated ARB parity fix: `961f584`.

| Check | Result |
| --- | --- |
| Initial full `flutter test --coverage --reporter expanded` | 1,490 passed, 1 skipped, 28 ARB parity failures; 4m12s |
| Complete ARB module after `961f584` | 117 passed |
| Final full `flutter test --no-pub --reporter expanded` | 1,518 passed, 1 skipped; 2m53s |
| Final `flutter analyze` after ARB fix | No issues (11.6s) |
| Final `dart format --output=none --set-exit-if-changed .` | 458 files, 0 changes |
| `git diff --check` | Clean |
| Exact CI coverage gate (80% overall, 60% per file) | Passed: 90.74% (9,536/10,509 lines), 203 files |

The initial integrated run identified 34 missing chart/statistics message keys in 28 locale ARB files; generated English fallback alone did not satisfy the repository parity guard. The fix adds the same English text and placeholder metadata to those catalogues. Regeneration produced SHA256-identical Dart for every generated file except `app_localizations_zh.dart`: 34 explicit `ZhHant` overrides were added, each with exactly the same method body as the previously inherited `Zh` method. This establishes runtime equivalence to the APK production source `1649714`; the ARB fix changes catalogue completeness, without changing displayed text or behavior. The complete parity module was rerun, and a final full test run was requested after this real failure/fix.

New-file coverage: graph model 96.8%, chart/lap widget 94.4%, statistics controller/API/models 100%, statistics response adapter 97.6%, statistics screen 88.5%. Generated localization files are excluded by the existing CI gate. The skipped test is the existing Apple-only adaptive list test on Linux.

Logs: `/tmp/endurain-v2-full-test.log`, `/tmp/endurain-v2-full-test-final.log`, `/tmp/endurain-v2-arb-parity.log`, `/tmp/endurain-v2-analyze-final.log`, `/tmp/endurain-v2-format-final.log`, `/tmp/endurain-v2-coverage.log`.

## Standards review

No remaining material documented-standard violations or baseline code smells identified after fixing the integrated localization parity finding in `961f584`. New HTTP operations stay behind replaceable repositories and the shared typed API client. Statistics has separate response parsing, immutable models and a controller owned through the existing AppServices/OwnedControllers path. Detail loading retains independent route, graph and lap failures. The new tab uses shared adaptive navigation; all added labels use localization catalogues. No dependencies, transport bypasses or native identity changes were introduced.

## Spec review

No remaining blocking feature-spec findings identified. Source comparison includes `frontend/src/features/activities/utils/{streams,format,activityType}.ts`, `backend/app/activities/activity_streams/`, `backend/app/activities/activity_laps/`, `backend/app/activities/activity_summaries/` and `backend/app/core/calendar.py` in the local server checkout.

- Charts render measured SI values with sport-specific pace/speed, swimming/rowing units, running cadence and temperature conversion. Missing/invalid/non-finite readings remain gaps; zero speed has no finite pace. True timestamps define elapsed time, and incomplete timestamps explicitly select measurement indices. One hundred thousand synthetic samples preserve peaks/gaps under bounded envelope rendering; selected readouts search the original samples.
- A review finding identified distance-free work laps being labelled recovery; the implementation now uses only explicit `intensity=rest`. A second finding reproduced finite tiny positive input overflowing reciprocal conversion; the test failed before the guard and passes after `1649714`. Recorded laps keep their actual distances; there are no fabricated kilometre splits.
- The statistics tab immediately shows distance from complete per-sport server aggregates, excluding non-distance sports. Counts, durations and elevation cover the full selected period. Week/month/year and named sport filtering use the summaries endpoint, independently of list pagination. UTC calendar semantics, the server weekday order and partial month weeks are explicit. All-sport trend bars show duration because the endpoint does not expose distance-excluded per-bucket aggregates; selected distance-sport bars show distance.
- Repository binding and controller generations discard late account/query/disposal work; logout clears visible data, guest mode issues no feature requests, and errors expose retries. Loading and data are independent across detail components. All new API calls are GET-only.
- Independent pixel rendering test `server_activity_chart_rendering_test.dart` verifies actual plotted segments on both sides of a missing measurement and no joining line through the gap. The generated local image `/tmp/endurain-v2-chart-review.png` was opened and visually checked: measured segments are distinct and fit the 360px card. Flutter widget-test Ahem fonts draw block glyphs in that artifact; text/unit assertions are covered separately by widget tests. Other chart tests exercise a 320px German dark card, a single sample, taps, imperial temperature/cadence and unequal actual lap distances.

## Limits

All request tests use synthetic transport; no private server, credentials or user activity data are contacted. No device was attached during this review. German and English new labels are supplied; other catalogues use the explicit English fallback text. Widget rendering and generated screenshots, when recorded below, validate synthetic layouts and charts rather than physical-device touch behavior or on-device frame rate. Real server/SSO/device checks must not be inferred from local automated success.

Review result: Standards — 0 remaining material findings. Spec — 0 remaining blocking findings. APK construction and signature/manifest evidence are documented separately in the Android handoff/build proof.
