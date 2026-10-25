# Endurain Flutter

The mobile client for Endurain, a self-hosted fitness tracking platform. It
records activities on-device, uploads them to the user's Endurain server, and
browses data held by that server.

## Language

**Offline read cache**:
A local copy of previously fetched server data, served for viewing when no
network is available. The server remains the source of truth.
_Avoid_: Offline mode, offline-first, local database

**Offline-first**:
An architecture where a local store is the primary source of truth and the
server is a sync peer that reconciles queued changes. Explicitly rejected for
this app; the app has an offline read cache instead.
_Avoid_: Sync engine, offline mode

**Cached view**:
A screen rendered from the offline read cache while offline, marked with the
time its data was last fetched from the server.
_Avoid_: Degraded mode, offline screen

**Identity**:
A specific (server, user) pairing. Cached data belongs to one identity and is
never served to another.
_Avoid_: Account, profile
