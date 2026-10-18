# Local v2 statistics

Supported server reference: checked-out Endurain v0.19.4, `backend/app/activities/activity_summaries/{router,crud,schema}.py`; web reference `frontend/src/features/summary/services/summary.ts`.

The Statistics tab calls authenticated `GET /api/v1/activities_summaries/{week|month|year}` through the shared ApiClient. Week/month send `date=YYYY-MM-DD`, year sends `year=YYYY`, sport filters send the server's returned `activity_type` name as `type`. These are database aggregates over the whole requested period, independent of activity-list pagination. No summaries are computed from the currently loaded activity page.

The repository, response adapter, typed models, controller and screen are separate files under `lib/features/statistics`. The repository is replaceable through `AppServices.createStatisticsController(repository: ...)`; screens can also receive a controller. Each request is bound to the active connection profile/origin. The repository rechecks after HTTP success and the controller rejects old account/query/refresh/disposal generations. Account changes clear all displayed totals and sport selections immediately. Guest mode makes no statistics requests. Refresh failures retain existing same-period totals with an explicit retry message; changed filters clear old totals.

## Scope and semantics

- Week, month and year controls, previous/next periods, duration, activity count, elevation gain, total distance, per-sport rows and filtering.
- Durations use `total_duration` (server sums `total_timer_time` seconds), distances and elevation use SI inputs and the existing app's unit/locale formatters. Swim filters and rows preserve sport-specific metre/yard units.
- Calendar boundaries match the web/server UTC database calendar. Week order and boundaries respect the server user's `first_day_of_week`; the app preserves the returned weekday order and labels `day_of_week` 0=Monday to6=Sunday. The week heading is explicitly an anchor date within the week. This does not claim device-local midnight boundaries.
- Month `week_number` means week1..6 within the month, clipped at month boundaries, not ISO week-of-year. Like the server, only month weeks with activities are displayed; the UI states this. Year contains calendar months.
- Overall distance is the sum of complete per-type aggregates for the distance-based sports, using the same sport classification as the existing activity detail/list formatter. Strength training, workout, yoga and other non-distance sports do not inflate kilometres. The overall duration/count/elevation still includes all sports. Per-sport rows keep different sports visible.
- The server's individual period buckets sum distance without excluding non-distance sports, while `type_breakdown` splits only the whole selected period. Therefore the all-sports trend displays **duration**. A selected distance sport displays its **distance** trend; a non-distance sport displays duration. The whole-period distance card remains visible immediately in the all-sports view. No dozens of extra per-sport requests are needed and no mixed bucket distance is presented as filtered kilometres.
- The server uses SQL `coalesce` for missing distance/time/elevation values. A server zero does not prove every activity recorded elevation. The app preserves these aggregate semantics; it does not imply sensor-data completeness.
- This version intentionally offers week/month/year, without lifetime totals, calorie cards, goals or activity editing. Server-unavailable/unsupported/malformed summary responses show an error, never a fabricated local-page total. The adapter requires the per-sport list supplied by v0.19.4 so that distance exclusion remains reliable.

## Verification

Targeted public-seam tests cover complete aggregate totals/Gym exclusion, malformed responses, late disconnected-account responses, controller account replacement, guest connect action, German dark-mode totals and period switching. `flutter analyze` on the statistics module, composition root and tab integration passes. Final full-suite/build evidence is recorded separately by the local verification workflow.
