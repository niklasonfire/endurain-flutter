# OsmAnd-hosted Endurain proof of concept

Date: 2026-10-21. Requested by the user: build a local OsmAnd fork using OsmAnd itself for recording and mapping, with the existing Endurain Flutter frontend on top. A proof of concept is sufficient. Delegate each implementation step to a subagent using the repository `implement` workflow. Do not replace OsmAnd with a reimplementation of its recorder.

## Baseline and scope

Parent repository baseline: `e51d41c6caeec01b259bb4c1f96417225960dc97`, current branch `feat/local-home-activity-recording`. Preserve pre-existing research notes and existing app behavior outside an explicit OsmAnd host mode. Local work only: no push, upstream PR, publication, installation or private-server requests.

Deliver one independently installable Android APK with a distinct application ID (`com.endurain.osmand.poc`) and launcher name. OsmAnd remains the Android Application and owns location collection, native map, recording persistence, pause/stop/save and native recovery. Flutter is an embedded frontend within that same app. This is not a launcher for a separately installed OsmAnd package.

Reuse existing Endurain login/SSO/session handling, home dashboard/goals, server activity list/search/filters, details/routes/charts/laps, statistics and settings. Preserve working health import and queue features where compatible. Recording/sensor/audio controls in host mode must use OsmAnd or clearly identify genuine limitations; never silently invoke the previous Endurain recorder. Original Endurain standalone mode remains available in source.

## Implementation steps and ownership

1. **OsmAnd host bootstrap — osmand_host.** Pin a real upstream commit on a stable branch, prepare a local source fork, preserve upstream source/licensing and create reproducible bootstrap/build scripts. Use existing SDKs. Use a local ignored source checkout plus tracked source lock/patches/overlays so a parent checkout can reproduce the fork. Source pin may change if a concrete compatibility issue requires it; record the final revision.
2. **Flutter embedding — osmand_flutter_frontend.** Generate a Flutter add-to-app module/AAR from the existing frontend source without maintaining a separate copied frontend. Configure explicit host mode and an independent SSO callback. Define the native host interface.
3. **OsmAnd recording integration — osmand_recording_bridge.** Implement an embedded FlutterFragmentActivity, native host channel, transitions to OsmAnd map/recording UI, required ordinary platform channels and callbacks. Keep the OsmAnd recorder and native lifecycle behavior intact.
4. **Saved GPX to Endurain — osmand_recording_bridge.** Discover saved OsmAnd recording GPX files, exclude ongoing recording data, preserve originals and transfer selected completed recordings into the existing local save-first upload queue. Explicit selection/import is acceptable for the PoC. Scope identities/provenance to prevent repeated or cross-account accidental imports, report real failures and allow retries.
5. **Integrated navigation — osmand_flutter_frontend.** Connect Record/map/settings actions to native OsmAnd and offer a clear return path to the embedded Endurain frontend. Keep full OsmAnd functionality reachable initially; hiding nonessential UI is optional.
6. **Validation, review and APK — delegated build/verification and review agents.** Run focused checks during implementation and the full existing Flutter suite once after integration. Compile the actual native host and build a single APK. Independently review Standards and Spec since the fixed parent baseline (and native patch/overlay against pinned upstream). Fix actionable findings. Verify APK package/version/signature/checksum and record exact source inputs and limitations.

## Host interface

`MethodChannel('endurain/osmand_host')` provides `openRecording` and `openMap`. The implementation agents agree a saved-recording descriptor/read interface before integrating imports. Recording collection must be independent of Flutter attachment. Original recorder startup/recovery must not run in host mode. SSO callback must differ from installed Endurain Local: proposed `endurain://osmand-auth/sso/callback`.

## Verification interfaces

Existing tests may be run immediately. The local TDD skill requires confirmed interfaces for new tests; parent has asked the user asynchronously to confirm these three interfaces:

1. Endurain ↔ OsmAnd navigation, with no startup of the previous recorder. Covers ownership and routing; does not prove real GNSS quality.
2. Completed GPX import with duplicate prevention. Covers preservation, completion eligibility and account/provenance rules; does not prove all OsmAnd save-dialog interactions.
3. Existing Endurain upload queue integration. Covers local save-before-upload, eligibility and retries; does not contact a private server or prove live credentials.

If no response, continue implementation with existing tests, static checks and native build verification; do not describe unapproved new tests as TDD. Confirmation is a test-method preference, not a requirement for further implementation work.

## Acceptance and honest limits

- Actual OsmAnd host source and build scripts are present locally and reproducible from tracked inputs.
- A single APK contains OsmAnd plus the existing Flutter frontend.
- Native map/Trip Recording is reachable from Endurain and Endurain is reachable from OsmAnd.
- Host mode cannot start the original native Endurain recorder.
- Finished native GPX recordings have an explicit route into the existing Endurain upload flow, retaining originals and avoiding repeat imports.
- Authentication callback and app identity do not collide with the existing local app.
- Automated checks and built artifact evidence are documented. Without an attached test device, background GNSS stability, process/reboot behavior, physical navigation and live authentication remain unverified; no claim of achieved OsmAnd-equivalent field reliability follows merely from compilation.
