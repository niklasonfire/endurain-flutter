# Recorded activity upload validation

Endurain 0.19.4 requires at least one GPX track segment with two GPS
trackpoints carrying valid times. A single point, no GPS points, or one point
on either side of a pause cannot form an uploadable route. Indoor recordings
without this data cannot be made uploadable by inventing coordinates or joining
across pauses.

The shared upload service validates the saved GPX with a namespace-aware XML
parser before contacting the server. Insufficient timed points and invalid XML
have separate localized messages. Both failures retain the local record and
original GPX for export/manual retry and disable background retries for that
permanent failure. Valid GPX 1.0/1.1, including prefixed namespaces, remains
supported. Existing profile-scoping and idempotency are unchanged.

The exporter now declares the Garmin trackpoint namespace for power-only
recordings too. Retry can add the historically omitted declaration to an
app-authored GPX in a temporary upload copy; the durable file is untouched,
sensor/coordinate/time values are preserved, and temporary copies are removed
after success or rejection.

Server failures retain a bounded, redacted FastAPI `detail` string or structured
`detail.code`/`detail.message`, alongside the HTTP status. Arbitrary JSON, HTML,
oversized bodies, malformed responses and stalled bodies fall back to the
status. Raw response bodies are never persisted or logged.

The reported indoor HTTP 400 is consistent with the GPX minimum-point contract;
its exact server response was not available. Multipart MIME was investigated
and is not the cause on the checked-out backend: its pinned safeuploads version
detects the file contents and accepts the default octet-stream upload.

Public upload/service/repository tests cover retained sparse recordings,
pause boundaries, valid namespaced GPX, malformed XML, a previously saved
power-only export, server rejection details and privacy bounds. Existing
recording/history/queue tests use actual valid two-point GPX on success paths.
