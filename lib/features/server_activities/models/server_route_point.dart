class ServerRoutePoint {
  const ServerRoutePoint({
    required this.latitude,
    required this.longitude,
    this.startsSegment = false,
  });

  /// The previous samples had no valid GPS; never join across this gap.
  final bool startsSegment;

  final double latitude;
  final double longitude;
}
