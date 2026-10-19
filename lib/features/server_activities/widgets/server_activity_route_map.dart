import 'package:endurain/core/constants/map_constants.dart';
import 'package:endurain/core/theme/app_theme_tokens.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

/// Interactive route, keeping missing GPS samples as separate line segments.
/// Flutter Map simplifies and culls the full track at the current zoom level.
class ServerActivityRouteMap extends StatefulWidget {
  const ServerActivityRouteMap({
    super.key,
    required this.route,
    required this.tileServerUrl,
    required this.startLabel,
    required this.finishLabel,
    this.selectedTime,
    this.effortStart,
    this.effortEnd,
  });
  final List<ServerRoutePoint> route;
  final String tileServerUrl;
  final String startLabel;
  final String finishLabel;
  final DateTime? selectedTime;
  final DateTime? effortStart;
  final DateTime? effortEnd;

  @override
  State<ServerActivityRouteMap> createState() => _ServerActivityRouteMapState();
}

class _ServerActivityRouteMapState extends State<ServerActivityRouteMap> {
  List<List<LatLng>> _segments = [];
  List<LatLng> _points = [];
  late ServerRoutePlayback _playback;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(ServerActivityRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.route, widget.route)) _prepare();
  }

  void _prepare() {
    _playback = ServerRoutePlayback(widget.route);
    _segments = [];
    _points = [];
    var segment = <LatLng>[];
    for (final point in widget.route) {
      final valid =
          point.latitude.isFinite &&
          point.longitude.isFinite &&
          point.latitude.abs() <= 90 &&
          point.longitude.abs() <= 180;
      if (!valid || point.startsSegment) {
        if (segment.isNotEmpty) _segments.add(segment);
        segment = [];
      }
      if (valid) {
        final coordinate = LatLng(point.latitude, point.longitude);
        segment.add(coordinate);
        _points.add(coordinate);
      }
    }
    if (segment.isNotEmpty) _segments.add(segment);
  }

  @override
  Widget build(BuildContext context) {
    if (_points.isEmpty) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final selected = _playback.at(widget.selectedTime);
    final bounds = LatLngBounds.fromPoints(_points);
    final singleLocation =
        bounds.north == bounds.south && bounds.east == bounds.west;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusCard),
      child: SizedBox(
        height: 300,
        child: FlutterMap(
          key: ObjectKey(widget.route),
          options: MapOptions(
            initialCenter: _points.first,
            initialZoom: MapConstants.initialLoadZoom,
            initialCameraFit: singleLocation
                ? null
                : CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(36),
                    maxZoom: MapConstants.initialLoadZoom,
                  ),
            minZoom: MapConstants.minZoom,
            maxZoom: MapConstants.maxZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: widget.tileServerUrl,
              userAgentPackageName: MapConstants.userAgent,
            ),
            PolylineLayer(
              polylines: [
                for (final segment in _segments)
                  if (segment.length > 1)
                    Polyline(
                      points: segment,
                      strokeWidth: ActivityRouteConstants.strokeWidth,
                      color: colors.primary,
                    ),
                for (final segment in _effortSegments())
                  Polyline(
                    points: segment,
                    strokeWidth: ActivityRouteConstants.strokeWidth + 3,
                    color: colors.tertiary,
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                if (selected != null)
                  Marker(
                    point: LatLng(selected.latitude, selected.longitude),
                    width: 24,
                    height: 24,
                    child: DecoratedBox(
                      key: const ValueKey('route-playback-marker'),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(blurRadius: 6, color: Colors.black38),
                        ],
                      ),
                    ),
                  ),
                _marker(
                  _points.first,
                  colors.primary,
                  Icons.play_arrow,
                  widget.startLabel,
                ),
                _marker(
                  _points.last,
                  colors.error,
                  Icons.flag,
                  widget.finishLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Clip each valid timed interval independently; never draw over missing fixes,
  // explicit sections, backwards timestamps or the adapter's 60-second gap rule.
  List<List<LatLng>> _effortSegments() {
    final start = widget.effortStart;
    final end = widget.effortEnd;
    if (start == null || end == null || !end.isAfter(start)) return const [];
    final result = <List<LatLng>>[];
    List<LatLng>? section;
    for (var i = 1; i < widget.route.length; i++) {
      final a = widget.route[i - 1];
      final b = widget.route[i];
      final at = a.time;
      final bt = b.time;
      final valid = [a, b].every(
        (p) =>
            p.latitude.isFinite &&
            p.longitude.isFinite &&
            p.latitude.abs() <= 90 &&
            p.longitude.abs() <= 180,
      );
      if (!valid ||
          at == null ||
          bt == null ||
          b.startsSegment ||
          !bt.isAfter(at) ||
          bt.difference(at).inMicroseconds > 60000000 ||
          !bt.isAfter(start) ||
          !at.isBefore(end)) {
        section = null;
        continue;
      }
      final left = at.isBefore(start) ? start : at;
      final right = bt.isAfter(end) ? end : bt;
      LatLng interpolate(DateTime time) {
        final fraction =
            time.difference(at).inMicroseconds /
            bt.difference(at).inMicroseconds;
        final longitudeDelta = ((b.longitude - a.longitude + 540) % 360) - 180;
        final longitude =
            ((a.longitude + longitudeDelta * fraction + 540) % 360) - 180;
        return LatLng(
          a.latitude + (b.latitude - a.latitude) * fraction,
          longitude,
        );
      }

      if (section == null) {
        section = [interpolate(left)];
        result.add(section);
      }
      section.add(interpolate(right));
    }
    return result;
  }

  Marker _marker(LatLng point, Color color, IconData icon, String label) =>
      Marker(
        point: point,
        width: 30,
        height: 30,
        child: Tooltip(
          message: label,
          child: Semantics(
            label: label,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(icon, color: Colors.white, size: 19),
            ),
          ),
        ),
      );
}
