import 'dart:math' as math;

import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/widgets/server_activity_list_item.dart';
import 'package:material_ui/material_ui.dart';
import 'package:endurain/l10n/app_localizations.dart';

class HomeActivityCard extends StatefulWidget {
  const HomeActivityCard({
    super.key,
    required this.activity,
    required this.loadRoute,
    required this.onTap,
  });
  final ServerActivity activity;
  final Future<List<ServerRoutePoint>> Function() loadRoute;
  final VoidCallback onTap;
  @override
  State<HomeActivityCard> createState() => _HomeActivityCardState();
}

class _HomeActivityCardState extends State<HomeActivityCard> {
  late final Future<List<ServerRoutePoint>> _route = widget.loadRoute();
  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FutureBuilder<List<ServerRoutePoint>>(
                  future: _route,
                  builder: (context, snapshot) {
                    final points = (snapshot.data ?? const <ServerRoutePoint>[])
                        .where(
                          (p) =>
                              p.latitude.isFinite &&
                              p.longitude.isFinite &&
                              p.latitude.abs() <= 90 &&
                              p.longitude.abs() <= 180,
                        )
                        .toList();
                    if (points.length < 2) {
                      return Icon(
                        ServerActivityListItem.sportIcon(activity.activityType),
                        color: theme.colorScheme.onPrimaryContainer,
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(7),
                      child: CustomPaint(
                        painter: _RoutePainter(
                          points,
                          theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activity.name.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context)!
                              .serverActivitySport('${activity.activityType}'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ServerActivityListItem(
                      activity: activity,
                      showSportIcon: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draw the actual route without loading tiles; GPS gaps remain disconnected.
class _RoutePainter extends CustomPainter {
  _RoutePainter(this.points, this.color);
  final List<ServerRoutePoint> points;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final centerLat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final longitudeScale = math
        .cos(centerLat * math.pi / 180)
        .abs()
        .clamp(0.01, 1);
    final xs = points.map((p) => p.longitude * longitudeScale).toList();
    final ys = points.map((p) => -p.latitude).toList();
    final minX = xs.reduce(math.min),
        maxX = xs.reduce(math.max),
        minY = ys.reduce(math.min),
        maxY = ys.reduce(math.max);
    final scale = math.min(
      size.width / math.max(maxX - minX, 0.000001),
      size.height / math.max(maxY - minY, 0.000001),
    );
    final dx = (size.width - (maxX - minX) * scale) / 2,
        dy = (size.height - (maxY - minY) * scale) / 2;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = dx + (xs[i] - minX) * scale, y = dy + (ys[i] - minY) * scale;
      if (i == 0 || points[i].startsSegment) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
