# Personal bests and achievements

## Purpose and source of truth

Endurain server activities are the source of truth. The app calculates personal bests and caches them on this device; the cache can be rebuilt from server history after reinstall or data loss. This is not server achievement synchronization. A replaceable `AchievementsRepository` boundary allows future official server records to supply the feature.

Only authenticated server activities participate in the first release. Pending local recordings do not participate, avoiding upload duplicates and records that cannot be rebuilt. Never upload records or modify source activities during analysis. Account scope is the existing `AuthSession.profileId`, which identifies server origin and account; no record, checkpoint or late result may cross that scope.

## First-release records

| Family | Targets | Value and winner |
| --- | --- | --- |
| Running fastest effort | 400 m, 1,000 m, 1 mile (1,609.344 m), 5,000 m, 10,000 m, half marathon (21,097.5 m), marathon (42,195 m) | Elapsed seconds over the exact continuous distance; lowest wins |
| Cycling fastest effort | 5,000 m, 10,000 m, 20,000 m, 40,000 m, 100,000 m | Elapsed seconds over the exact continuous distance; lowest wins |
| Longest activity | One activity's distance | Metres; highest wins |
| Longest duration | One activity's recorded timer duration | Seconds; highest wins |
| Most climbing | One activity's server elevation gain | Metres; highest wins |
| Biggest week | Per-sport total distance and timer duration in a calendar week | Metres or seconds; highest wins |
| Biggest month | Per-sport total distance and timer duration in a calendar month | Metres or seconds; highest wins |

Expose all-time and calendar-year filters. Each sport variant has its own records, including trail running, treadmill/indoor sports, cycling variants and e-bikes. Preserve the server's numeric activity-type identity; the local recording `ActivityType` enum is too broad. Sport eligibility comes from the verified server activity-type mapping, not from pace-versus-speed formatting. Running distances apply only to running variants, cycling distances to cycling variants. Non-distance sports may have duration records but must not gain invented distance records.

Milestone badges, streaks, custom goals, power records, swimming-specific distance efforts and cross-device achievement synchronization are outside the first release.

## Time, calendar and ties

Distance efforts use elapsed timestamp differences, including stationary samples and recorded stops. Timer or moving time must never substitute for those differences. Supplied segment boundaries and inferred discontinuities split the stream: an effort cannot cross them. The verified v0.19.4 API exposes timestamped GPS but no cumulative-distance or pause stream, and its GPX importer flattens original segment boundaries. Therefore this release offers **estimated GPS bests**, cannot guarantee detection of every original pause, and must state that limitation. Conservatively inferred gaps are not proof that all pauses were detected.

Summary duration records and weekly/monthly duration totals use `timerSeconds`, matching existing Statistics `total_timer_time` semantics. Do not substitute elapsed duration silently. Missing timer duration excludes only that metric; the activity may still contribute distance or elevation. Labels should say recorded duration where the distinction matters.

Calendar buckets follow the server UTC database calendar described in [statistics-api-contract.md](statistics-api-contract.md). Use an absolute server start instant for period and year attribution. An offset-free display time is not an instant and must not be assigned the device timezone or an invented UTC offset. Missing absolute dates allow all-time per-activity records but exclude yearly/period records, with a reason shown in analysis coverage.

Weeks use the server user's `first_day_of_week`; changing that preference invalidates weekly aggregates. If this preference cannot be obtained reliably, weekly records are unavailable until it can be resolved. Months are calendar months, not rolling 30-day windows. Assign whole activities by start date, as Statistics does; do not split their summary totals across midnight.

A year filter first selects activities starting in that UTC year, then groups their summaries into weeks/months. Cross-year weeks are clipped to the selected year; their displayed period start/end must describe the clipped range. Label these partial weeks so users can interpret comparisons with full weeks. All-time weeks retain their full calendar boundaries.

Compare stored, unrounded numeric values. Equal displayed values need not be ties. Exact numeric ties resolve by earliest activity UTC start (missing starts last), then lowest numeric server activity ID, then earliest effort start offset. A tied period resolves to the earliest period start. Preserve previous winners so future record feedback can distinguish an improvement from deterministic tie replacement.

## Distance calculation and quality

For the verified v0.19.4 contract, derive cumulative distance from validated raw timestamped GPS coordinates and retain `gpsDerived` provenance. Its available stream types contain no recorded cumulative-distance or pause data. A future adapter may supply trustworthy raw recorded-distance samples with distinct provenance, but must not invent support now. Never infer a fastest kilometre from an activity average, lap average or display-downsampled chart stream. Indoor summary distance alone does not establish an indoor distance effort.

An effort is an exact-distance window anywhere inside one continuous segment, not just a window starting on a kilometre marker. Interpolate boundary times along each valid distance interval. Compare boundary configurations at both sample-distance and target-shifted sample-distance positions, so an optimum whose end lies at a sample is not missed. Preserve fractional time and distance until formatting. Stationary intervals keep elapsed time; repeated distances must not imply instantaneous travel.

Raw timestamps must be finite, ordered and strictly increasing across travelled intervals; cumulative distance must be finite, nonnegative and nondecreasing within a segment. Missing/malformed points, resets, explicit pauses, excessive gaps and implausible jumps break continuity. No interpolation across a rejected interval. A valid neighbouring segment may still produce a record. Adapter policy must document and version any sport-specific gap/jump thresholds and test boundary behavior; use the existing conservative greater-than-60-second gap convention unless the shared engine policy explicitly documents an alternative. Thresholds are quality guards, not physiological proof or record certification. A shorter unmarked pause cannot always be distinguished from recording behavior; describe GPS efforts as estimates.

Summary metrics are usable independently when finite and positive; missing and negative values never become measured zeros. Elevation records use server gain, not a fresh sum of noisy GPS altitude samples. Record provenance identifies summary, recorded-distance stream or GPS-derived distance. Preserve activity source fingerprint, calculation version, sample/effort boundaries and skip reasons. If the server has no reliable revision identifier, a metadata fingerprint cannot prove an unchanged stream: disclose that a full rebuild refetches streams to detect such edits.

## Domain and persistence boundaries

Use small immutable domain models under `lib/features/achievements/`, separate from HTTP, SQLite and Flutter widgets. The proposed shared vocabulary is:

- `AchievementActivity`: server ID, exact sport identity, optional absolute start, summary SI metrics, fingerprint and raw normalized samples.
- `AchievementSample`: timestamp, cumulative metres and segment identity or explicit boundary marker. No display sampling.
- `AchievementCandidate`: source activity ID, sport, record kind, optional target distance, unrounded SI value, activity date, optional effort boundaries and provenance.
- A record key: sport, record kind, optional target distance and all-time/year context; period candidates also identify their calendar start/end.
- An analysis result: candidates, calculation version and structured exclusions/quality reasons.
- A scan state: account scope, resumable checkpoint, inventory generation, progress/coverage, completion/error state and last successful analysis time.

Exact constructor names are implementation details; keep these meanings stable across engine, store, scanner and screen. The engine has no HTTP, persistence or UI dependency. Persist candidates for all eligible source activities, not only winners, so deleting or editing a winner reveals the next best without losing history. Period aggregates must retain/rebuild their contributing activity IDs for navigation and reconciliation.

Use a dedicated migrated SQLite store. Candidate replacement and checkpoint advancement are atomic. A successful activity refresh replaces that activity's prior analysis; a failed refresh retains the prior result and marks it stale. Calculation version changes invalidate affected derived results. Never silently present mixed-version results as complete.

## Analysis and synchronization

Scan complete authenticated server history in bounded batches. Fetch detailed streams only where needed; summary-only records still work when streams are unavailable. Keep heavy calculations off the UI thread. Save progress and resume after interruption, cancellation or process restart. Start with a server inventory generation, not the currently loaded activity-list page.

A scan is complete only after every page is successfully fetched and each discovered activity is analysed or explicitly classified as skipped/unavailable. Track inventory coverage separately from stream eligibility: scanning 100% of history does not mean every activity supports fastest efforts. A failed API request is retryable, not a permanent quality exclusion.

Refresh new or changed activities incrementally. Periodic successful inventory reconciliation detects historical imports and deletions. Remove an absent activity only after a complete successful authoritative inventory; a failed/truncated page must never erase records. Deduplicate IDs and detect unstable pagination. If consistency cannot be established, retain records, mark coverage incomplete and retry. Recalculate affected winners and period totals after edits/deletions.

Every asynchronous operation captures account identity and generation, rechecks after awaits, and rejects results after account switch/disposal. Account changes immediately clear visible records. Guest mode makes no authenticated requests. A full rebuild refetches all relevant inputs; keep the current cache visibly stale until a consistent replacement is ready rather than destroying useful records before a network request succeeds.

## User experience

Add Personal bests under Statistics with sport and all-time/year filters. Show record result, units, date and activity link. Running efforts show elapsed time plus pace; cycling efforts show elapsed time plus speed. Effort detail highlights the winning map stretch when coordinates exist. Missing map data does not invalidate a valid recorded-distance effort. Period cards show date range and navigate to contributing activities rather than pretending one activity owns the total.

Always identify locally calculated results: “Calculated on this device.” During incomplete scans use “Best found so far.” Show last successful analysis, progress/coverage, skipped/unavailable data with understandable reasons, retry and rebuild actions. Distinguish guest, not analysed, analysing, partial, complete, empty and refresh-failed states. An empty history differs from history containing activities without usable streams. A failure retains same-account results with an explicit stale/retry indication.

Initial history analysis produces no burst of achievement celebrations. Later confirmed improvements may show previous value and improvement; recalculation, restored cache and tie replacement must not masquerade as a new athletic achievement. Format with existing locale and measurement-system conventions, and provide translations through the app's localization files.

## Approved acceptance seams

The user approved these five public TDD boundaries. Implement behavior in vertical red/green slices; do not test private helpers or mirror algorithms in expected assertions.

1. **Calculation engine:** exact running/cycling target windows, interpolation, stops, gaps, invalid points, variants, ties, summary/period semantics and independently worked examples. This seam excludes HTTP and widgets.
2. **Store/repository:** round-trip persistence and migration, account isolation, candidate replacement, next-best promotion, atomic checkpointing and version handling. Observe through its public interface rather than querying internal tables.
3. **Server adapter:** verified API parsing, raw-stream validity, provenance, absolute-versus-display timestamps and explicit capability/unavailable outcomes. Do not fabricate unsupported streams.
4. **Scan/controller:** interrupted resume, retry without data loss, successful-inventory-only deletion, pagination consistency, incremental/historical imports, generation cancellation and late account responses.
5. **Screen/navigation:** progress/partial/error/empty/guest states, filters and formatted results, retained stale records, activity/period links and effort highlighting where available.

Run focused tests per slice, analysis/type checks during implementation and the full suite once after integration. Review against this specification and repository standards before the root agent commits. This work does not authorize a push, publication, installation or pull request to the original repository.
