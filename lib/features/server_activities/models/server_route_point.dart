class ServerRoutePoint {
  const ServerRoutePoint({
    required this.latitude,
    required this.longitude,
    this.startsSegment = false,
    this.time,
  });

  /// The previous samples had no valid GPS; never join across this gap.
  final bool startsSegment;

  final DateTime? time;

  final double latitude;
  final double longitude;
}

/// Matches actual recorded GPS samples; never extrapolates through missing GPS.
class ServerRoutePlayback {
  ServerRoutePlayback(List<ServerRoutePoint> route)
    : _points =
          route
              .where(
                (p) =>
                    p.time != null &&
                    p.latitude.isFinite &&
                    p.longitude.isFinite &&
                    p.latitude.abs() <= 90 &&
                    p.longitude.abs() <= 180,
              )
              .toList()
            ..sort((a, b) => a.time!.compareTo(b.time!));

  final List<ServerRoutePoint> _points;

  ServerRoutePoint? at(DateTime? time) {
    if (time == null || _points.isEmpty) return null;
    var low = 0;
    var high = _points.length;
    while (low < high) {
      final mid = (low + high) ~/ 2;
      if (_points[mid].time!.isBefore(time)) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    if (low < _points.length && _points[low].time == time) return _points[low];
    if (low == 0 || low == _points.length) return null;
    final before = _points[low - 1];
    final after = _points[low];
    if (after.startsSegment ||
        after.time!.difference(before.time!).inMilliseconds > 60000) {
      return null;
    }
    final left = time.difference(before.time!).inMilliseconds;
    final right = after.time!.difference(time).inMilliseconds;
    // A distant GPS sample cannot reliably locate this measurement.
    if (left <= right && left <= 5000) return before;
    if (right < left && right <= 5000) return after;
    return null;
  }
}
