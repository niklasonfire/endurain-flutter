# Endurain on OsmAnd: Android proof of concept

This is a source overlay onto the complete OsmAnd Android application, not a
replacement recorder and not an external-app integration. The upstream
`OsmandApplication`, foreground service, monitoring plugin, track storage, maps
and controls remain in the same APK. An embedded Flutter module provides the
existing Endurain frontend; its recording entry opens OsmAnd's native UI.

## Build

Use the existing SDK/signing inputs in `BUILDING_LOCAL.md` at the repository
root. These helpers reuse that toolchain and never create a signing key.

```bash
./tool/osmand/build-frontend.sh
./tool/osmand/build-host.sh
```

The frontend helper creates a disposable module under `build/osmand-poc`.
The host helper aligns its build with AGP 8.13.2 / Gradle 8.13, Kotlin 2.4.0 and D8/R8 9.1.31
(the Flutter plugin dependencies require AGP >=8.9.1 and Kotlin 2.4 metadata),
using the existing JDK17 / Android SDK36 / build-tools36.0.0. It prepares pinned upstream sources, overlays tracked native
extensions, and builds `androidFullOpenglArm64Release`. The output lives under
`poc/osmand/upstream/OsmAnd/build/outputs/apk/`. Only arm64 devices are supported
by this PoC. Installation and publication are separate actions.

`ENDURAIN_FLUTTER_REPO` overrides the local frontend Maven repository;
`ENDURAIN_FLUTTER_ARTIFACT` overrides its coordinate (default
`dev.endurain.osmand.frontend:flutter_release:1.0`).
`ENDURAIN_SIGNING_PROPERTIES` may point to the existing private properties file.
No credentials or APKs belong in Git.

## Source and native provenance

`sources.json` pins OsmAnd and OsmAnd-resources commits on upstream's r5.3
release line. OsmAnd has no modern release Git tags. `prepare.py` downloads the
original official 5.3.0 APK and verifies its SHA256 before extracting only
`libosmand.so` and `libc++_shared.so` for arm64. It does not copy the original
application classes or install that APK. OpenGL core remains the official 5.3
Ivy AAR dependency declared by upstream. The legacy JNI source build is skipped
because its old external Skia/dependency toolchain is unnecessary for this PoC.
The release-branch source commit and official APK both declare version 5.3.0;
the official APK does not provide a verifiable exact source-commit mapping.
This compatibility assumption must be checked on a device. Upstream remote
Ivy assets and basemap downloads are versioned URLs rather than vendored
hash-locked dependencies; preserve a successful dependency cache for repeat
builds.

The upstream checkout and resources are ignored local build inputs. Only the
manifest, integration configuration, overlays and prepare/build scripts are
tracked. Preparing again restores only named generated integration files, then
reapplies overlays. Do not edit those generated upstream files directly.

Package: `com.endurain.osmand.poc`; launcher: `Endurain OsmAnd PoC`.
SSO callback: `endurain://osmand-auth/sso/callback`.
The app has its own Android sandbox; existing Endurain/OsmAnd credentials,
tracks and settings are not automatically migrated. Backup is disabled for
this PoC to avoid inheriting OsmAnd backup rules for Endurain credentials.

## License

Retain upstream OsmAnd license/copyright notices. OsmAnd is GPLv3; this combined
proof of concept is derived from it. The source repositories and recorded
revisions are listed in `sources.json`. Any eventual binary distribution must
provide the corresponding complete source and satisfy upstream and dependency
licenses. The original APK download is an ignored build input, not a tracked
redistributable artifact. See upstream `LICENSE` and resource/core license
notices at their pinned source revisions.
