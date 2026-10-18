import 'dart:math' as math;

/// Wire values stay in server SI units, including pace in seconds/metre.
enum ServerGraphMetric {
  heartRate(1, 'hr'),
  power(2, 'power'),
  cadence(3, 'cad'),
  elevation(4, 'ele'),
  speed(5, 'vel'),
  pace(6, 'pace'),
  temperature(8, 'temp');

  const ServerGraphMetric(this.streamType, this.field);
  final int streamType;
  final String field;
}

class ServerGraphPoint {
  const ServerGraphPoint(this.x, this.value, {this.startsSegment = false});
  final double x;
  final double? value;
  final bool startsSegment;
}

class ServerActivityGraph {
  ServerActivityGraph._(this.metric, this.hasTimeAxis, this._points);

  factory ServerActivityGraph.fromJson(Map<String, dynamic> json) {
    final metric = ServerGraphMetric.values.firstWhere(
      (metric) => metric.streamType == json['stream_type'],
    );
    final rows = json['stream_waypoints'] as List<dynamic>;
    final times = rows
        .map((row) => row is Map ? serverGraphTimestamp(row['time']) : null)
        .toList();
    // Missing timestamps must not imply evenly travelled distance or time.
    final timed = times.isNotEmpty && times.every((time) => time != null);
    final points = <ServerGraphPoint>[];
    double? previousX;
    for (var i = 0; i < rows.length; i++) {
      final x = timed
          ? times[i]!.difference(times.first!).inMilliseconds / 1000
          : i.toDouble();
      final row = rows[i];
      final raw = row is Map ? row[metric.field] : null;
      var value = serverGraphNumber(raw);
      if (metric == ServerGraphMetric.pace && (value == null || value <= 0)) {
        value = null;
      }
      if (metric != ServerGraphMetric.elevation &&
          metric != ServerGraphMetric.temperature &&
          value != null &&
          value < 0) {
        value = null;
      }
      if (previousX != null && x <= previousX) continue;
      points.add(
        ServerGraphPoint(
          x,
          value,
          startsSegment: previousX != null && timed && x - previousX > 60,
        ),
      );
      previousX = x;
    }
    return ServerActivityGraph._(metric, timed, List.unmodifiable(points));
  }

  final ServerGraphMetric metric;
  final bool hasTimeAxis;
  final List<ServerGraphPoint> _points;
  bool get hasValues => _points.any((point) => point.value != null);

  /// Exact reciprocal conversion, preserving zero-speed stops as gaps.
  ServerActivityGraph paceFromSpeed() {
    if (metric != ServerGraphMetric.speed) {
      throw StateError('Velocity required');
    }
    return ServerActivityGraph._(
      ServerGraphMetric.pace,
      hasTimeAxis,
      List.unmodifiable(
        _points.map(
          (point) => ServerGraphPoint(
            point.x,
            point.value != null ? _positiveRatio(1, point.value!) : null,
            startsSegment: point.startsSegment,
          ),
        ),
      ),
    );
  }

  /// Envelope sampling keeps extrema and explicit gaps while bounding paint cost.
  /// Raw samples remain available for precise reading through [nearest].
  List<ServerGraphPoint> points({int budget = 1200}) {
    if (_points.length <= budget) return _points;
    final result = <ServerGraphPoint>[];
    final size = (_points.length / math.max(1, budget ~/ 5)).ceil();
    for (var start = 0; start < _points.length; start += size) {
      final end = math.min(start + size, _points.length);
      var min = start;
      var max = start;
      int? gap;
      for (var i = start; i < end; i++) {
        final value = _points[i].value;
        if (value == null || _points[i].startsSegment) gap ??= i;
        if (value != null &&
            (_points[min].value == null || value < _points[min].value!)) {
          min = i;
        }
        if (value != null &&
            (_points[max].value == null || value > _points[max].value!)) {
          max = i;
        }
      }
      final indices = {start, end - 1, min, max, ?gap}.toList()..sort();
      var broken = false;
      for (final i in indices) {
        // If a bucket has any gap, avoid joining its retained envelope samples.
        result.add(
          ServerGraphPoint(
            _points[i].x,
            _points[i].value,
            startsSegment: _points[i].startsSegment || (gap != null && broken),
          ),
        );
        broken = true;
      }
    }
    return List.unmodifiable(result);
  }

  ServerGraphPoint? nearest(double x) {
    if (_points.isEmpty) return null;
    var low = 0;
    var high = _points.length - 1;
    while (low < high) {
      final mid = (low + high) ~/ 2;
      if (_points[mid].x < x) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    if (low > 0 &&
        (x - _points[low - 1].x).abs() <= (_points[low].x - x).abs()) {
      return _points[low - 1];
    }
    return _points[low];
  }
}

class ServerActivityLap {
  const ServerActivityLap({
    required this.distanceMeters,
    required this.seconds,
    required this.speed,
    required this.heartRate,
    required this.isRest,
  });
  factory ServerActivityLap.fromJson(Map<String, dynamic> json) {
    final distance = serverGraphNumber(json['total_distance']);
    final seconds =
        serverGraphNumber(json['total_timer_time']) ??
        serverGraphNumber(json['total_elapsed_time']);
    final pace = serverGraphNumber(json['enhanced_avg_pace']);
    final speed = serverGraphNumber(json['enhanced_avg_speed']);
    return ServerActivityLap(
      distanceMeters: distance,
      seconds: seconds,
      speed: speed != null && speed > 0
          ? speed
          : pace != null && pace > 0
          ? _positiveRatio(1, pace)
          : distance != null && distance > 0 && seconds != null && seconds > 0
          ? _positiveRatio(distance, seconds)
          : null,
      heartRate: serverGraphNumber(json['avg_heart_rate']),
      isRest: json['intensity'] == 'rest',
    );
  }
  final double? distanceMeters;
  final double? seconds;
  final double? speed;
  final double? heartRate;
  final bool isRest;
}

double? serverGraphNumber(Object? value) =>
    value is num && value.isFinite ? value.toDouble() : null;
DateTime? serverGraphTimestamp(Object? value) {
  if (value is! String || value.isEmpty) return null;
  final zoned = RegExp(
    r'(Z|[+-]\d{2}:?\d{2})$',
    caseSensitive: false,
  ).hasMatch(value);
  return DateTime.tryParse(zoned ? value : '${value}Z')?.toUtc();
}

/// Invalid derived values are gaps, just like invalid wire measurements.
double? _positiveRatio(double numerator, double denominator) {
  if (denominator <= 0) return null;
  final value = numerator / denominator;
  return value.isFinite && value > 0 ? value : null;
}
