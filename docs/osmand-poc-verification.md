# OsmAnd / Endurain PoC: local verification

Verified on 21 October 2026. This is a successfully built, signed, single APK.
It has **not been installed or exercised on a device**. Recording stability,
background recovery, permission flows and Endurain server round trips remain
manual device checks; compilation does not establish GPS reliability.

## Artifact

[Release APK](../build/local-artifacts/endurain-osmand-poc-0.1.0+1-arm64-release.apk)

- Absolute path: `/home/nilius/chadrc-home/endurain-flutter/build/local-artifacts/endurain-osmand-poc-0.1.0+1-arm64-release.apk`.
- Package: `com.endurain.osmand.poc`; launcher: **Endurain OsmAnd PoC**.
- Version: `0.1.0-poc`, versionCode **1**; release, not debuggable.
- Size: **389,509,246 bytes** (371.5 MiB); **arm64-v8a only**.
- minSdk **26**, targetSdk **35**, compileSdk **36**.
- SHA256: `8c55132f3fcf99dd00a8522e3f83f4d47049fa9ea7b4b291344d937c02911b5d`.
- `apksigner verify` succeeded, APK Signature Scheme v2. Existing persistent
  certificate SHA256: `3341bbf406214b746b6f893d12a353652df6c9215feb6b2e58e541c2bb9dfb6e`.
  No signing identity was generated or replaced.

The APK and logs are ignored local build artifacts, not committed binaries.
Nothing was installed, pushed, published or submitted as a pull request.

## Source and build inputs

- Frozen Endurain application source: `1de725f79d520084786607065b96d3836df4fc4c`.
- Host overlays/build configuration represented by commit
  `b660374e341b7bbc0b74683eccd2e99184ab945e`.
- Frontend source digest: `1327f12a87a11bb9e8a12566ea2e2734e1dc74830bd0cf643466bbeb7c268698`.
  This hashes sorted relative paths and contents under `lib/` and `assets/`,
  plus `pubspec.yaml`, `pubspec.lock` and `l10n.yaml`, with NUL separators.
- OsmAnd source: r5.3, `3b2db4c2c2b68ffc920ca023e5ae84d379fb17e6`.
- OsmAnd resources: r5.3, `c2fe578126a7a6f142a6c5f4bc966bd3e7a0bfc6`.
- Legacy JNI input: official `net.osmand-5.3.0.apk` (versionCode 5300),
  SHA256 `7e4ce9a12014bf781670dd40147f0267d41e9e4b46b424d06665109d186023da`.
  Its arm64 `libosmand.so` input SHA256 is
  `8185d802e87dad324f21f6d315050742702ce967e129efb8b2b59d13c9120fec`.
  The Android build strips native debug symbols as usual.
- OpenGL core: upstream-declared official OsmAnd 5.3 Ivy AARs.
- Flutter 3.47.3 / Dart 3.13.3, existing JDK 17, Android SDK 36 and build-tools 36.0.0.
- Host: AGP 8.13.2, Gradle 8.13, Kotlin compiler 2.4.0 with original **2.1
  language/API mode**, D8/R8 explicitly 9.1.31. These satisfy the Flutter
  plugin dependencies' AGP >=8.9.1 and Kotlin 2.4 bytecode requirements while
  retaining upstream's Gradle APIs and source language behavior.

The APK's embedded `META-INF/version-control-info.textproto` identifies the
nested pinned OsmAnd checkout, not the outer overlay repository. Source/native
release compatibility is documented in [the bootstrap README](../poc/osmand/README.md):
the official APK has no independently verifiable exact source-commit mapping.
No recording-service, location-filter or persistence implementation was replaced.

Build commands are in [the bootstrap README](../poc/osmand/README.md).
The final frontend AAR build succeeded in 372.7 seconds. Native
`:OsmAnd:assembleAndroidFullOpenglArm64Release` exited 0 in 5m35s
(158 tasks: 45 executed, 113 up-to-date).

## Checks completed

- Existing complete Flutter suite: **1,590 passed, 1 skipped**, exit 0, 6m48s;
  full analyzer: **no issues**, exit 0; formatter: **482 files, 0 changes**.
- Integrated upstream OsmAnd Java suite: **531 tests in 19 suites**, zero
  failures/errors/skips. Native Android instrumentation tests were not run.
- Native Kotlin, Java, resource linking, duplicate-class check, D8 processing,
  packaging and signing completed. Kotlin 2.1 mode preserved compatibility
  without patching the three upstream UI files rejected by2.4 language mode.
- Actual APK manifest identifies **OsmandApplication**, the original
  **NavigationService**, and **EndurainFlutterActivity** as the launcher.
  The old Endurain `ActivityRecorderService` is absent.
- All seven Endurain Health Connect read permissions and the rationale/usage
  activity alias are present; SSO uses `endurain://osmand-auth/sso/callback`.
  Backup is disabled for the PoC.
- ZIP inspection confirms 17 Flutter asset entries and arm64 `libapp.so`,
  `libflutter.so`, `libosmand.so`, `libOsmAndCoreWithJNI.so`, Qt libraries and
  the additional plugin libraries. No other ABI is packaged.
- `apkanalyzer dex packages --defined-only` confirms definitions for
  EndurainFlutterActivity, OsmandApplication, NavigationService and
  OsmandMonitoringPlugin; no legacy Endurain ActivityRecorderService.
- The root orchestrator independently repeated package/version/SDK/launcher,
  manifest, ZIP/ABI, size, SHA256 and signature checks with matching results.
- The two review axes and resolved findings are recorded in
  [the review report](osmand-poc-review.md).

## Known build diagnostics

Release Lint completed under upstream's `abortOnError=false`, but its bundled
Kotlin analysis cannot fully read Kotlin 2.4 standard-library metadata
(expected 2.2). Therefore this is **not a clean native static-analysis result**.
The actual Kotlin compiler and D8/R8 are 2.4-compatible and completed successfully.
Existing deprecation warnings and a Google location-library companion-metadata
warning also remain.

AAPT reports `STRING_TOO_LARGE` for upstream `h_bare_rock2.xml`: its vector
pathData contains 40,847 UTF-8 bytes. The same placeholder is already in the
original official 5.3.0 APK (drawable resource 0x7f080341, packaged as
`res/I0E.xml`), verified directly in that APK. This concerns a rock-pattern
resource and was retained; it is not a newly introduced recording change.

The first bootstrap attempt let AGP select/install build-tools 34 for the
shared module. The reproducible configuration now pins shared/main/API builds
to 36.0.0 and disables automatic SDK downloading. No additional Flutter SDK,
JDK, Android platform, signing key or device installation was performed.

## Remaining PoC limits

Saved OsmAnd GPX recordings are manually imported into the existing Endurain
workflow. Import provenance persists after local-history deletion. Legacy
Endurain sensor/audio settings are disabled with an explanation; native
OsmAnd's own configuration remains reachable. The separate package has its
own Android sandbox, so existing app data is not migrated.

First device pass:

1. Open Endurain and select **Record**. In native OsmAnd, complete any first-run
   setup, grant precise location/notification permissions, and use the Trip
   Recording plugin's original start controls.
2. Record with the screen off, then stop and **save** the track in OsmAnd.
3. Use the **Endurain** return button. Open **Settings → OsmAnd recordings**,
   refresh if necessary, select the saved GPX and import it into the existing
   Endurain workflow; then verify its upload to the selected account/server.
4. Repeat with pause/resume, offline operation and a process interruption.

A real-device pass must also cover first-run setup/permissions, native recording,
return to Endurain, screen-off recording, process interruption, GPX import,
login/SSO and server upload. This build provides the artifact for that pass.

## Local evidence

All paths below are ignored build output:

- `build/osmand-poc/host-build.log` — successful final native build.
- `build/osmand-poc/frontend-aar.log` — final source snapshot/AAR build.
- `build/osmand-poc/final-flutter-tests.log`, `final-flutter-analyze.log`,
  `final-dart-format.log` — complete Flutter verification.
- `build/osmand-poc/apk-badging.txt`, `apk-signature.txt`, `apk-manifest.xml`,
  `apk-contents.json`, `apk-dex-packages.txt`, `build-inputs.json` — actual APK
  and source-input evidence.
- Failed/cancelled bootstrap attempts are preserved separately as
  `host-build-initial-agp.log`, `host-build-agp-bootstrap.log`,
  `host-build-navigation-dependency.log`, `host-build-kotlin24-ui.log` and
  `host-build-language-source-sets.log`.
