---
name: android-build
description: Build and verify the local Endurain Android APK using the established Flutter/Android toolchain and persistent signing identity. Use for APK builds, update builds, and Android build troubleshooting in this repository.
---

# Local Android APK

Use [BUILDING_LOCAL.md](../../../BUILDING_LOCAL.md) for the exact host paths,
signing-reference example, build command, and artifact verification. Read it
before running a build; it removes the need to explore the backend or rediscover
SDKs.

1. Check `git status --short` and the current branch. The local Home/activity
   changes are on `feat/local-home-activity-recording`; the fork's default
   `main` does not contain them. If a requested local-feature build is on a clean
   default checkout, switch to the existing remote feature branch. Preserve a
   dirty checkout and resolve its intended source before switching.
2. Use one Flutter SDK consistently for dependency resolution, analysis, tests,
   and the APK. Reuse the documented Android SDK, JDK17, Gradle cache and Flutter
   settings. Do not run concurrent builds/tests against different SDKs.
3. For an update, reuse the existing private signing identity. A fresh clone
   does not contain the key or `android/key.properties`. The existing
   `tool/build-local-android.sh` generates a new key when that file is absent:
   **do not invoke it blindly in a fresh clone**. Use the guide's private
   signing reference/export instead. Never print credentials, copy keys into
   tracked files, or substitute a new key for an installed app's update key.
4. An unchanged-source artifact rebuild needs the build and finished-APK checks;
   do not automatically rerun the full Flutter suite, investigate the backend,
   run `flutter clean`, or upgrade dependencies. For changed source, run checks
   appropriate to that change; an integrated feature delivery needs full checks.
5. Supply build name/number as Flutter overrides rather than modifying a dirty
   `pubspec.yaml`. The last verified update was `0.11.1+21`; a subsequent update
   must exceed the installed/latest delivered versionCode. Inspect existing
   artifacts or the user's requested version before choosing it.
6. Build locally, preserve a versioned APK and build log, and verify the actual
   new output: package, versionCode, release signature matching the previous
   local APK, and checksum. Record the source commit and any working changes.
   Report the absolute APK path, mode, version, size, and verification result.

For failures, inspect the first concrete error in the captured build log and
correct that cause. The known Health/Kotlin future-migration warning alone is
not a failed build. A native-assets `Invalid SDK hash` after mixing SDKs calls
for the documented SDK and its dependency resolution first, not a toolchain
upgrade or a clean by default. If the existing signing inputs or SDK are
unavailable, report the exact missing input; do not create replacement keys or
silently download a different toolchain.

APK builds do not authorize installation, releases, pushes, or PRs. Never push
to or create a PR targeting `endurain-project/endurain-flutter`. When GitHub
publication is separately requested, verify the destination is the user's
`niklasonfire/endurain-flutter` fork.
