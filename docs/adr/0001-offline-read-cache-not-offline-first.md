# Offline read cache instead of offline-first sync

Server-backed screens currently show nothing without network. We decided to add
an offline read cache — a local, raw-payload copy of what the server already
returned, served for viewing while offline — rather than an offline-first sync
engine, because the pain is reading data in the field, not editing it; the one
write that matters in the field (activity uploads) is already handled by the
existing upload queue.

## Considered Options

- **Offline-first (local store as source of truth, server as sync peer)**:
  rejected — roughly an order of magnitude more work, requires conflict
  resolution, and no user demand for offline edits exists.
- **Fallback-only cache (populate only on failed fetch)**: rejected — the first
  offline session after a fresh install would still show nothing. Every
  successful fetch writes the cache instead (cache-through).

## Consequences

- Offline is read-only: edits (gear, goals, activity deletion) still require
  the server.
- Cached payloads are stored raw, not parsed into model rows, so server schema
  changes break parsing at read time exactly as they would a live fetch.
- A future offline-first migration would replace this cache wholesale; the
  per-identity keying established here carries over.
