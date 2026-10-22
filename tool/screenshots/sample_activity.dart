// Read public, licensed GPX recordings for documentation previews.
import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';

class SampleActivity {
  SampleActivity._(this.activity, this.route, this.graphs);

  final ServerActivity activity;
  final List<ServerRoutePoint> route;
  final List<ServerActivityGraph> graphs;

  factory SampleActivity.read(File file, int id) {
    final document = XmlDocument.parse(file.readAsStringSync());
    final points = <_Point>[];
    var newSegment = true;
    for (final segment in document.descendants.whereType<XmlElement>().where(
      (element) => element.name.local == 'trkseg',
    )) {
      newSegment = true;
      for (final element in segment.childElements.where(
        (element) => element.name.local == 'trkpt',
      )) {
        String? value(String name) => element.descendants
            .whereType<XmlElement>()
            .where((child) => child.name.local == name)
            .firstOrNull
            ?.innerText;
        final time = DateTime.tryParse(value('time') ?? '')?.toUtc();
        if (time == null) continue;
        final point = _Point(
          LatLng(
            double.parse(element.getAttribute('lat')!),
            double.parse(element.getAttribute('lon')!),
          ),
          time,
          double.tryParse(value('ele') ?? ''),
          double.tryParse(value('hr') ?? ''),
          newSegment,
        );
        if (points.isNotEmpty && !time.isAfter(points.last.time)) continue;
        points.add(point);
        newSegment = false;
      }
    }
    if (points.length < 2) {
      throw StateError('GPX needs timed track points: ${file.path}');
    }
    const distance = Distance(roundResult: false);
    var meters = 0.0;
    var gain = 0.0;
    final cumulative = <double>[0];
    for (var i = 1; i < points.length; i++) {
      final before = points[i - 1], point = points[i];
      if (!point.startsSegment) {
        meters += distance.as(
          LengthUnit.Meter,
          before.coordinate,
          point.coordinate,
        );
        if (before.elevation != null && point.elevation != null) {
          final climb = point.elevation! - before.elevation!;
          if (climb > 0) gain += climb;
        }
      }
      cumulative.add(meters);
    }
    final duration = points.last.time.difference(points.first.time).inSeconds;
    if (duration <= 0 || meters <= 0) {
      throw StateError('Invalid GPX summary: ${file.path}');
    }
    final heartRates = points
        .map((point) => point.heartRate)
        .whereType<double>()
        .toList();
    final name = file.uri.pathSegments.last
        .replaceAll('.gpx', '')
        .replaceAll('_', ' ');
    final graphs = <ServerActivityGraph>[];
    final speedRows = <Map<String, dynamic>>[
      // Keep the graph's time origin aligned with the activity. There is no
      // speed estimate before the second GPS fix, so that value stays absent.
      {'time': points.first.time.toIso8601String(), 'vel': null},
    ];
    var windowStart = 0;
    for (var i = 1; i < points.length; i++) {
      final point = points[i];
      if (point.startsSegment) windowStart = i;
      // Average GPS speed over a trailing 20-second window, avoiding a noisy
      // single-fix derivative. Never bridge separate GPX track segments.
      while (windowStart + 1 < i &&
          point.time.difference(points[windowStart + 1].time).inSeconds >= 20) {
        windowStart++;
      }
      final seconds =
          point.time.difference(points[windowStart].time).inMilliseconds / 1000;
      speedRows.add({
        'time': point.time.toIso8601String(),
        'vel': seconds > 0
            ? (cumulative[i] - cumulative[windowStart]) / seconds
            : null,
      });
    }
    graphs.add(
      ServerActivityGraph.fromJson({
        'stream_type': 5,
        'stream_waypoints': speedRows,
      }),
    );
    for (final (type, key, values) in [
      (1, 'hr', points.map((point) => point.heartRate).toList()),
      (4, 'ele', points.map((point) => point.elevation).toList()),
    ]) {
      if (values.every((value) => value == null)) continue;
      graphs.add(
        ServerActivityGraph.fromJson({
          'stream_type': type,
          'stream_waypoints': [
            for (var i = 0; i < points.length; i++)
              {'time': points[i].time.toIso8601String(), key: values[i]},
          ],
        }),
      );
    }
    return SampleActivity._(
      ServerActivity(
        id: id,
        name: name,
        activityType: 1,
        startTime: points.first.time,
        distanceMeters: meters,
        elapsedSeconds: duration.toDouble(),
        timerSeconds: duration.toDouble(),
        averageSpeedMetersPerSecond: meters / duration,
        elevationGainMeters: points.any((point) => point.elevation != null)
            ? gain
            : null,
        averageHeartRate: heartRates.isEmpty
            ? null
            : heartRates.reduce((a, b) => a + b) / heartRates.length,
      ),
      points
          .map(
            (point) => ServerRoutePoint(
              latitude: point.coordinate.latitude,
              longitude: point.coordinate.longitude,
              time: point.time,
              startsSegment: point.startsSegment,
            ),
          )
          .toList(),
      graphs,
    );
  }
}

class _Point {
  const _Point(
    this.coordinate,
    this.time,
    this.elevation,
    this.heartRate,
    this.startsSegment,
  );
  final LatLng coordinate;
  final DateTime time;
  final double? elevation;
  final double? heartRate;
  final bool startsSegment;
}

List<SampleActivity> readSampleActivities() {
  final files =
      Directory('tool/screenshots/fixtures')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.gpx'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (files.isEmpty) throw StateError('No licensed GPX fixtures found');
  final samples = [
    for (var i = 0; i < files.length; i++) SampleActivity.read(files[i], i + 1),
  ]..sort((a, b) => b.activity.startTime!.compareTo(a.activity.startTime!));
  return samples;
}

StatisticsMetrics sumMetrics(Iterable<SampleActivity> samples) => samples.fold(
  StatisticsMetrics.zero,
  (total, sample) => StatisticsMetrics(
    distanceMeters: total.distanceMeters + sample.activity.distanceMeters!,
    durationSeconds: total.durationSeconds + sample.activity.timerSeconds!,
    elevationMeters:
        total.elevationMeters + (sample.activity.elevationGainMeters ?? 0),
    count: total.count + 1,
  ),
);
