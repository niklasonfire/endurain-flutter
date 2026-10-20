# OsmAnd proof-of-concept code review

Date: 2026-10-21. Independent Standards and Spec review agents examined the
implementation against the fixed parent baseline
`e51d41c6caeec01b259bb4c1f96417225960dc97`.

Reviewed HEAD: `1de725f79d520084786607065b96d3836df4fc4c`. The exact committed
comparison was:

```bash
git diff e51d41c6caeec01b259bb4c1f96417225960dc97...HEAD
```

The reviewers also inspected the pending `tool/osmand/build-host.sh` worktree
change adding `--refresh-dependencies`. Native review covered tracked overlays,
source preparation and host configuration against the pinned OsmAnd source;
ignored upstream sources are build inputs, not parent-repository changes.
The implementation spec is [osmand-poc-plan.md](osmand-poc-plan.md).

## Standards

Zero remaining material actionable findings at the reviewed revision.

The three original findings were resolved:

- Widgets obtain the shared, injectable `OsmandHostBridge` through `AppServices`;
  standalone and unsupported builds receive `UnsupportedOsmandHostBridge`.
  Importer dependencies, including the provenance ledger, are injected.
- `AppConfig` owns the host flag. Startup, recovery, sensors, navigation and
  recorder guards use the injected configuration. The static SSO callback uses
  the compile-time default from the same configuration class. No old
  `isOsmandHost` callers remain.
- Native return-button text and spacing use resources. Health permission
  rationale uses localized resources.

The first UI architecture guard failure was corrected in `667b458` by using
standalone Material UI in the OsmAnd recordings screen. The native activity's
broad responsibilities remain a possible Divergent Change smell, a judgment
call deliberately deferred within the user's proof-of-concept scope. Minor
resource placement and layout polish are not material blockers.

## Spec

Both prior P2 findings are resolved; no remaining material Spec findings.

Audio and sensor tiles are disabled in host mode with a localized limitation.
A separate persistent import ledger survives local-history deletion. Content
identity blocks renamed or copied duplicates; existing rows backfill their
original destination; a missing row with a ledger entry produces the
`previouslyImported` result.

Save ordering allows retry backfill after interruption between row upsert and
ledger write. The narrow two-store crash window, if the recovery row is manually
deleted before retry, is not a material proof-of-concept blocker. Host ownership
and SSO remain coherent after flag centralization.

This is source review, not APK or device evidence. Native build and final test
validation were still pending when this report was written; their outcome is
recorded separately in [osmand-poc-verification.md](osmand-poc-verification.md).
No builds or tests were run by these review agents.

Standards: zero remaining material actionable findings; deferred architecture
polish only. Spec: zero remaining material findings.
