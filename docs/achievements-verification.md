# Personal bests verification

The acceptance contract is [achievements-spec.md](achievements-spec.md). The
inspected server inputs and their limitations are documented in
[achievements-server-contract.md](achievements-server-contract.md).

## Public boundaries

The user approved tests at five public boundaries: calculation engine,
store/repository, server adapter, scan/controller, and screen/navigation. Tests
observe results through those interfaces; HTTP fixtures replace only the network
transport and persistence tests use SQLite through its FFI database factory.

The lifecycle integration test at
`test/features/achievements/integration/achievements_lifecycle_test.dart` runs the
real API client, server adapter, calculator, scanner, repository, disk-backed
SQLite store and screen controller together. It verifies:

- A GPS-derived kilometre best with an independent equatorial distance reference,
  elapsed timing, provenance and effort boundaries.
- Closing and reopening the database restores results and coverage without HTTP.
- An unchanged metadata fingerprint reuses the cache; a full rebuild discovers
  changed raw GPS despite unchanged summary metadata.
- An interrupted rebuild checkpoints its remaining raw work; reopening the disk
  database and using ordinary refresh completes that work despite unchanged
  summary fingerprints.
- A complete successful inventory plus confirmed deletion promotes the surviving
  next-best activity.

The scanner tests additionally cover unavailable GPS with useful summaries,
unstable pagination, unconfirmed deletion, retained records after failed rebuild,
retry, and late account responses. Engine, repository, adapter and widget tests
cover their respective approved contracts.

## Performance sample

Measured on 2026-10-19 using the verified local Dart 3.13.3 toolchain on Linux x64
with eight logical processors. This is a development-machine JIT sample, not an
Android latency guarantee. Each operation ran in `Isolate.run`, including worker
startup and input/result transfer. After one warm-up, five runs measured:

| Operation | Input | Median | Range |
| --- | --- | --- | --- |
| GPS effort calculation | 100,000 timestamped cumulative-distance samples, seven running targets | 940.7 ms | 866.3–1,118.4 ms |
| Historical record aggregation | 20,000 summary analyses across running/cycling | 393.5 ms | 336.3–586.0 ms |

The benchmark fixture was `/tmp/endurain-achievements-benchmark.dart`; it did not
add production instrumentation or performance thresholds to the test suite. It
measures the calculation boundary on normalized raw samples, excluding HTTP,
GPS decoding and SQLite I/O. Device profiling is still needed to characterize
mobile memory use and complete historical scan time.

## Review

Independent Standards and Spec reviews used starting commit
`69be6ec722681c496912e4cdab0d44dc56e17965`. Review corrections cover reopened
screens deriving their own records from the shared cache, explicit retry guidance
for partial stale results, typed error codes, and a shared record
selection policy. The Standards review's two P2 findings and duplication
judgment were addressed; the Spec review's two P2 findings were addressed. Both
final reviews report no remaining P1/P2 or Spec findings.

Public UI regressions demonstrated reopened-cache and stale-result failures
before the fixes. Nine focused UI/Statistics tests and 36 focused standards-fix
tests passed afterward. Statistics assertions now identify the aggregate card
instead of depending on duplicate labels simultaneously occupying a lazy-list
viewport.

## Verification status

Final checks on 2026-10-19 used the existing local Flutter toolchain:

| Check | Result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed .` | Passed: 494 files, zero changes |
| `flutter analyze --no-pub` | Passed: no issues |
| `flutter test --coverage --no-pub --reporter expanded` | Passed: 1,617 tests, one skipped, 3 min 54 sec |
| Documented `tool/check_coverage.dart` gate from `CONTRIBUTING.md` | Global coverage passed at 90.42% (11,402/12,610 lines across 223 files); per-file gate failed only on the unchanged BLE adapter |

The coverage command used the documented 80% global and 60% per-file thresholds
and all six documented exclusions. Its sole failure is
`lib/features/sensors/services/universal_ble_sensor_connection_adapter.dart` at
7.69% (9/117 lines); this file has no changes against the approved baseline.
Every achievements file clears the per-file threshold. No coverage threshold was
lowered and no extra file was excluded.

The initial diagnostic full run exposed the Statistics viewport assertion and
reopened-cache regression described above. Both were fixed and covered by
focused checks before the final passing full run. Logs are retained locally at
`/tmp/endurain-achievements-format-final.log`,
`/tmp/endurain-achievements-analyze-final.log`,
`/tmp/endurain-achievements-suite-final.log`, and
`/tmp/endurain-achievements-coverage-final.log`.

## Product limits

Records are calculated on this device from server activities. Pending local
recordings are excluded. A lost cache can be rebuilt from available server
history; this feature does not synchronize achievement records across devices.
GPS efforts are estimates, and the inspected server provides no explicit pause
or cumulative-distance stream. Its flattened GPS can hide original segment
boundaries. Conservative discontinuity checks cannot recover every pause.

A matching summary fingerprint cannot establish that raw GPS is unchanged; a
full rebuild refetches streams. Initial and restored historical results produce
no achievement celebrations. No live server, APK build, installation, push,
publication or upstream pull request is part of this verification.
