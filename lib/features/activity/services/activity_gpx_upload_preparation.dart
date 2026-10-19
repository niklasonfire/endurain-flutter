import 'package:endurain/core/models/app_exception.dart';
import 'package:xml/xml.dart';

/// Validate the GPX import contract without changing the durable recording.
/// Returns the original bytes unless the old app exporter omitted a namespace.
String prepareActivityGpxUpload(String source) {
  try {
    var document = XmlDocument.parse(source);
    var root = document.rootElement;
    const namespaces = {
      null,
      'http://www.topografix.com/GPX/1/0',
      'http://www.topografix.com/GPX/1/1',
    };
    if (root.name.local != 'gpx' || !namespaces.contains(root.namespaceUri)) {
      throw const AppException(AppErrorCode.activityUploadInvalidGpx);
    }

    var repaired = false;
    // Only repair the exact historical exporter defect. Never reserialize or
    // guess at arbitrary imported documents, coordinates, or recording times.
    if (root.getAttribute('creator') == 'Endurain mobile app' &&
        root.getAttribute(
              'gpxtpx',
              namespaceUri: 'http://www.w3.org/2000/xmlns/',
            ) ==
            null &&
        document.descendantElements.any((e) => e.name.prefix == 'gpxtpx')) {
      root.attributes.add(
        XmlAttribute(
          const XmlName.parts(
            'gpxtpx',
            prefix: 'xmlns',
            namespaceUri: 'http://www.w3.org/2000/xmlns/',
          ),
          'http://www.garmin.com/xmlschemas/TrackPointExtension/v1',
        ),
      );
      repaired = true;
      // Parsed XmlName bindings are immutable; resolve them again after adding
      // the missing declaration before checking namespaces and track segments.
      document = XmlDocument.parse(document.toXmlString());
      root = document.rootElement;
    }
    if (document.descendantElements.any(
      (e) => e.name.prefix != null && e.namespaceUri == null,
    )) {
      throw const AppException(AppErrorCode.activityUploadInvalidGpx);
    }

    Iterable<XmlElement> children(XmlElement parent, String name) =>
        parent.childElements.where(
          (element) =>
              element.name.local == name &&
              element.namespaceUri == root.namespaceUri,
        );
    for (final track in children(root, 'trk')) {
      for (final segment in children(track, 'trkseg')) {
        var count = 0;
        for (final point in children(segment, 'trkpt')) {
          final lat = double.tryParse(point.getAttribute('lat') ?? '');
          final lon = double.tryParse(point.getAttribute('lon') ?? '');
          final time = children(point, 'time').firstOrNull?.innerText;
          if (lat != null &&
              lat.isFinite &&
              lon != null &&
              lon.isFinite &&
              time != null &&
              DateTime.tryParse(time.trim()) != null) {
            count++;
            if (count >= 2) return repaired ? document.toXmlString() : source;
          }
        }
      }
    }
    throw const AppException(AppErrorCode.activityUploadInsufficientGps);
  } on AppException {
    rethrow;
  } on XmlException {
    throw const AppException(AppErrorCode.activityUploadInvalidGpx);
  }
}
