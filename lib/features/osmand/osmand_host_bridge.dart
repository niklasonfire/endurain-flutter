
import 'package:flutter/services.dart';

class OsmandRecording {
  const OsmandRecording({
    required this.id,
    required this.name,
    required this.size,
    required this.modifiedAt,
  });
  final String id;
  final String name;
  final int size;
  final DateTime modifiedAt;
}

/// Reads only saved OsmAnd GPX files; the native recorder owns active sessions.
class OsmandHostBridge {
  const OsmandHostBridge();
  static const _channel = MethodChannel('endurain/osmand_host');
  Future<void> openMap() => _channel.invokeMethod<void>('openMap');
  Future<void> openRecording() => _channel.invokeMethod<void>('openRecording');
  Future<List<OsmandRecording>> listCompletedRecordings() async {
    final entries =
        await _channel.invokeListMethod<dynamic>('listCompletedRecordings') ??
        [];
    return entries.map((dynamic entry) {
      final map = entry as Map;
      return OsmandRecording(
        id: map['id'] as String,
        name: map['name'] as String,
        size: map['size'] as int,
        modifiedAt: DateTime.fromMillisecondsSinceEpoch(
          map['modifiedAt'] as int,
          isUtc: true,
        ),
      );
    }).toList();
  }

  Future<Uint8List> readCompletedRecording(OsmandRecording recording) async {
    final bytes = await _channel.invokeMethod<Uint8List>(
      'readCompletedRecording',
      {'id': recording.id},
    );
    if (bytes == null) throw StateError('OsmAnd returned no saved recording.');
    return bytes;
  }
}
