# Server activity list

The Activities tab sits between Home and Statistics. It loads only activities of
current server credentials through `ServerActivitiesRepository`, newest first.
Search, exact sport type, and inclusive date range are server-side filters.
Pull to refresh replaces the first page; scrolling near the end or Load more
fetches the next page. Page failures keep current rows and provide a separate
retry action. Failed refreshes preserve existing rows with an inline error.
Filter changes reset pagination immediately, so a failed first-page request
cannot continue at a page inherited from the previous filter. Retry starts at
page one. The controller exposes immutable list snapshots, replaced only on
updates, so reading a card does not copy the complete loaded history.

`ServerActivitiesController` takes the repository and a
`ValueListenable<String?>` connection identity. Production wiring uses
`AuthSessionStore.connectionChanges`: origin-qualified profile changes and
logout invalidate rows, filters, types, and pending responses immediately.
Token refresh retains the profile identity. Request generations also reject
responses superseded by a refresh or filter change. Pending search text is
cancelled and cleared when the account changes.

## Detail navigation seam

`ServerActivitiesScreen.onOpenActivity` is a
`ValueChanged<ServerActivity>` callback. The Activities builder in
`shared/widgets/app_bottom_nav.dart` can connect this to an adaptive push of
`ServerActivityDetailScreen(activityId: activity.id)`. Tests inject the callback
and assert the selected server activity ID. Detail state must independently
observe the active connection identity and reject old responses.

The list reuses `HomeActivityCard` from the Home screen: a real route thumbnail
(or sport icon when GPS is unavailable), localized sport label, activity name,
date/location, and compact sport-specific metrics. The shared
`ServerActivityListItem` supplies the established date and metric formatting.
Its static
`usesPace`, `isDistanceBased`, and `sportIcon` methods are also available to the
detail screen. Distances, duration, elevation, speed and pace use the existing
`ActivityStatsFormatterScope` and device/user unit preference.

German and English strings, including all 47 server sport labels, live in the
existing ARB catalogs. Other locale catalogs currently use English for new
messages. The sport label is an ICU select, so the localization parity test
extracts argument names recursively rather than mistaking branch labels for
placeholders.

Targeted tests cover account-switch and stale-query responses, pagination
failure/retry, session identity events, guest sign-in, German text, dark-theme
rows, search, filter reset, detail selection, and pending-search cancellation.

## Route preview loading

Cards are built only for the visible viewport (`scrollCacheExtent` is zero),
so opening the list does not fetch GPS routes for the whole page or history.
`ServerActivitiesController.loadRoute` permits at most two route requests in
flight and deduplicates repeated requests in a forty-entry least recently used
cache. Scrolling back can reuse previews without another request. Evicted
queued requests are skipped before accessing the server. Account changes,
filter changes, and disposal invalidate cached and pending route responses.
Failed or unavailable routes keep the activity card usable with its sport icon.
Transient failures are evicted, and pull to refresh rebinds visible previews so
they can retry. Successful previews and legitimate empty GPS-less routes remain
cached across refreshes.
Actual GPS segment boundaries remain disconnected in the thumbnail.
