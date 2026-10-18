import 'dart:math' as math;

import 'package:endurain/core/models/measurement_system.dart';
import 'package:endurain/features/activity/services/activity_stats_formatter_scope.dart';
import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:endurain/features/server_activities/services/server_activity_formatter.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Chart rendering and reading are isolated from HTTP/loading state.
class ServerActivityCharts extends StatelessWidget {
  const ServerActivityCharts({
    super.key,
    required this.graphs,
    required this.activityType,
  });
  final List<ServerActivityGraph> graphs;
  final int activityType;

  @override
  Widget build(BuildContext context) {
    final pace = ServerActivityFormatter.usesPace(activityType);
    final hasPace = graphs.any(
      (graph) => graph.metric == ServerGraphMetric.pace,
    );
    final sportGraphs = pace && !hasPace
        ? graphs.map(
            (graph) => graph.metric == ServerGraphMetric.speed
                ? graph.paceFromSpeed()
                : graph,
          )
        : graphs;
    final visible =
        sportGraphs
            .where(
              (graph) => switch (graph.metric) {
                ServerGraphMetric.pace => pace,
                ServerGraphMetric.speed => !pace,
                ServerGraphMetric.elevation =>
                  activityType != 8 && activityType != 9,
                _ => true,
              },
            )
            .toList()
          ..sort((a, b) => _order(a.metric).compareTo(_order(b.metric)));
    if (visible.isEmpty) return Text(AppLocalizations.of(context)!.chartNoData);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final graph in visible)
          ServerActivityChart(
            key: ValueKey(graph.metric),
            graph: graph,
            activityType: activityType,
          ),
      ],
    );
  }

  static int _order(ServerGraphMetric metric) => switch (metric) {
    ServerGraphMetric.pace || ServerGraphMetric.speed => 0,
    ServerGraphMetric.heartRate => 1,
    ServerGraphMetric.elevation => 2,
    ServerGraphMetric.power => 3,
    ServerGraphMetric.cadence => 4,
    ServerGraphMetric.temperature => 5,
  };
}

class ServerActivityChart extends StatefulWidget {
  const ServerActivityChart({
    super.key,
    required this.graph,
    required this.activityType,
  });
  final ServerActivityGraph graph;
  final int activityType;
  @override
  State<ServerActivityChart> createState() => _ServerActivityChartState();
}

class _ServerActivityChartState extends State<ServerActivityChart> {
  late List<ServerGraphPoint> _points;
  double _fraction = 0;
  @override
  void initState() {
    super.initState();
    _points = widget.graph.points();
  }

  @override
  void didUpdateWidget(ServerActivityChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graph != widget.graph) {
      _points = widget.graph.points();
      _fraction = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_points.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final stats = context.statsFormatter;
    final locale = context.numberFormatLocale;
    final formatter = ServerActivityFormatter(
      stats: stats,
      l10n: l10n,
      locale: locale,
    );
    final metric = widget.graph.metric;
    final title = switch (metric) {
      ServerGraphMetric.heartRate => l10n.activityStatHeartRate,
      ServerGraphMetric.power => l10n.activityStatPower,
      ServerGraphMetric.cadence => l10n.chartCadence,
      ServerGraphMetric.elevation => l10n.statsElevation,
      ServerGraphMetric.speed => l10n.activityStatSpeed,
      ServerGraphMetric.pace => l10n.activityStatPace,
      ServerGraphMetric.temperature => l10n.chartTemperature,
    };
    String value(double? value) {
      if (value == null) return '—';
      return switch (metric) {
        ServerGraphMetric.heartRate => stats.formatHeartRate(value.round()),
        ServerGraphMetric.power => stats.formatPower(value.round()),
        ServerGraphMetric.cadence =>
          {1, 2, 3, 34, 40}.contains(widget.activityType)
              ? '${NumberFormat('0', locale).format(value * 2)} ${l10n.chartSpm}'
              : stats.formatCadence(value.round()),
        ServerGraphMetric.elevation => stats.formatElevation(
          value,
          locale: locale,
        ),
        ServerGraphMetric.speed => formatter.tempo(value, widget.activityType),
        ServerGraphMetric.pace => formatter.tempo(
          1 / value,
          widget.activityType,
        ),
        ServerGraphMetric.temperature =>
          '${NumberFormat('0.0', locale).format(stats.system == MeasurementSystem.imperial ? value * 9 / 5 + 32 : value)} °${stats.system == MeasurementSystem.imperial ? 'F' : 'C'}',
      };
    }

    String axis(double x) => widget.graph.hasTimeAxis
        ? stats.formatDuration(x.round())
        : NumberFormat('0', locale).format(x + 1);
    final first = _points.first.x;
    final last = _points.last.x;
    final selected = widget.graph.nearest(first + (last - first) * _fraction)!;
    final values = _points.map((point) => point.value).whereType<double>();
    final minimum = values.isEmpty ? 0.0 : values.reduce(math.min);
    final maximum = values.isEmpty ? 1.0 : values.reduce(math.max);
    final color = Theme.of(context).colorScheme.primary;
    final reading = '${axis(selected.x)} · ${value(selected.value)}';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${value(minimum)} – ${value(maximum)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (event) => setState(
                  () => _fraction =
                      (event.localPosition.dx / constraints.maxWidth).clamp(
                        0.0,
                        1.0,
                      ),
                ),
                onHorizontalDragUpdate: (event) => setState(
                  () => _fraction =
                      (event.localPosition.dx / constraints.maxWidth).clamp(
                        0.0,
                        1.0,
                      ),
                ),
                child: Semantics(
                  label: '$title. ${l10n.chartReadHint}',
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: CustomPaint(
                      key: ValueKey('chart-${metric.name}'),
                      painter: _GraphPainter(
                        points: _points,
                        minimum: minimum,
                        maximum: maximum,
                        color: color,
                        gridColor: Theme.of(context).colorScheme.outlineVariant,
                        selectedX: selected.x,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(axis(first)), Text(axis(last))],
            ),
            Text(
              widget.graph.hasTimeAxis
                  ? l10n.chartTimeAxis
                  : l10n.chartSampleAxis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                reading,
                key: ValueKey('reading-${metric.name}'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Slider(
              value: _fraction,
              onChanged: last == first
                  ? null
                  : (value) => setState(() => _fraction = value),
              label: reading,
              semanticFormatterCallback: (_) => reading,
            ),
            Text(
              l10n.chartReadHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  const _GraphPainter({
    required this.points,
    required this.minimum,
    required this.maximum,
    required this.color,
    required this.gridColor,
    required this.selectedX,
  });
  final List<ServerGraphPoint> points;
  final double minimum;
  final double maximum;
  final Color color;
  final Color gridColor;
  final double selectedX;
  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTWH(
      3,
      6,
      math.max(1, size.width - 6),
      math.max(1, size.height - 12),
    );
    final minX = points.first.x;
    final rangeX = points.last.x - minX;
    final rangeY = maximum - minimum;
    double x(double value) =>
        plot.left + (rangeX == 0 ? 0.5 : (value - minX) / rangeX) * plot.width;
    double y(double value) =>
        plot.bottom -
        (rangeY == 0 ? 0.5 : (value - minimum) / rangeY) * plot.height;
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final height = plot.top + plot.height * i / 2;
      canvas.drawLine(
        Offset(plot.left, height),
        Offset(plot.right, height),
        grid,
      );
    }
    final line = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = color;
    Offset? previous;
    for (final point in points) {
      if (point.value == null) {
        previous = null;
        continue;
      }
      final current = Offset(x(point.x), y(point.value!));
      if (previous != null && !point.startsSegment) {
        canvas.drawLine(previous, current, line);
      }
      // Dots preserve isolated measurements and small streams.
      if (points.length < 50 || previous == null || point.startsSegment) {
        canvas.drawCircle(current, 2, dot);
      }
      previous = current;
    }
    canvas.drawLine(
      Offset(x(selectedX), plot.top),
      Offset(x(selectedX), plot.bottom),
      grid,
    );
  }

  @override
  bool shouldRepaint(_GraphPainter oldDelegate) =>
      points != oldDelegate.points ||
      minimum != oldDelegate.minimum ||
      maximum != oldDelegate.maximum ||
      color != oldDelegate.color ||
      gridColor != oldDelegate.gridColor ||
      selectedX != oldDelegate.selectedX;
}

class ServerActivityLaps extends StatelessWidget {
  const ServerActivityLaps({
    super.key,
    required this.laps,
    required this.activityType,
  });
  final List<ServerActivityLap> laps;
  final int activityType;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = context.statsFormatter;
    final formatter = ServerActivityFormatter(
      stats: stats,
      l10n: l10n,
      locale: context.numberFormatLocale,
    );
    if (laps.isEmpty) return Text(l10n.chartLapsEmpty);
    // Expansion keeps activities with hundreds of laps compact and readable.
    return ExpansionTile(
      title: Text('${l10n.chartLaps} (${laps.length})'),
      children: [
        for (var i = 0; i < laps.length; i++)
          ListTile(
            title: Text(
              '${l10n.chartLap} ${i + 1}${laps[i].isRest ? ' · ${l10n.chartRest}' : ''}',
            ),
            subtitle: Text(
              [
                if (laps[i].distanceMeters != null)
                  formatter.distance(laps[i].distanceMeters!, activityType),
                if (laps[i].seconds != null)
                  stats.formatDuration(laps[i].seconds!.round()),
                if (!laps[i].isRest && laps[i].speed != null)
                  formatter.tempo(laps[i].speed!, activityType),
                if (laps[i].heartRate != null)
                  stats.formatHeartRate(laps[i].heartRate!.round()),
              ].join(' · '),
            ),
          ),
      ],
    );
  }
}
