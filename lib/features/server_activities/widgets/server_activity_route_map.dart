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
  });
  final List<ServerRoutePoint> route;
  final String tileServerUrl;
  final String startLabel;
  final String finishLabel;
  final DateTime? selectedTime;

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
