import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdb;
import 'package:timezone/timezone.dart' as tz;

/// An activity's displayed start time, which can be either a wall clock time
/// already converted by Endurain or an ISO timestamp with an explicit offset.
/// An explicit-offset instant renders in the recorded location's IANA time
/// zone when the server supplied one, and in device-local time otherwise.
///
/// Offset-free API values do not identify an instant. In particular, they must
/// never gain a `Z` suffix or be converted into the device's time zone again.
class ServerActivityStartTime {
  const ServerActivityStartTime._(
    this._calendarFields,
    this.instantUtc,
    this._recordedTimeZone,
  );

  // UTC is only a calendar carrier here, avoiding device DST normalization of
  // wall clock fields. For naive input it does NOT represent an actual instant.
  final DateTime _calendarFields;

  /// The actual instant, available only when the input specified its offset.
  final DateTime? instantUtc;

  /// IANA zone the activity was recorded in, when the server supplied one.
  final String? _recordedTimeZone;

  bool get isAbsolute => instantUtc != null;

  static bool _timeZoneDatabaseLoaded = false;

  /// Parses the bundled IANA time zone database once per process.
  ///
  /// [format] calls this itself, so no caller depends on initialization
  /// order; `main` also calls it eagerly so the first server-activities
  /// screen does not pay the one-time parse during its first build.
  static void ensureTimeZoneDatabase() {
    if (_timeZoneDatabaseLoaded) return;
    tzdb.initializeTimeZones();
    _timeZoneDatabaseLoaded = true;
  }

  /// Matches the web client's preference for the activity's local start time.
  /// Malformed preferred values fall back to the other API field.
  static ServerActivityStartTime? fromApi({
    Object? timezoneApplied,
    Object? fallback,
    Object? timezone,
  }) {
    final zone = timezone is String && timezone.trim().isNotEmpty
        ? timezone.trim()
        : null;
    final start = _parse(timezoneApplied) ?? _parse(fallback);
    return start == null
        ? null
        : ServerActivityStartTime._(
            start._calendarFields,
            start.instantUtc,
            zone,
          );
  }

  /// Formats wall clock fields unchanged; absolute timestamps render in the
  /// recorded time zone and fall back to device time when it is absent or
  /// unknown to the bundled database.
  String format(DateFormat formatter) {
    final instant = instantUtc;
    if (instant == null) return formatter.format(_calendarFields);
    final zone = _recordedTimeZone;
    if (zone != null) {
      ensureTimeZoneDatabase();
      try {
        return formatter.format(
          tz.TZDateTime.from(instant, tz.getLocation(zone)),
        );
      } on tz.LocationNotFoundException {
        // A zone the database does not know falls back to device-local
        // display instead of blanking the field.
      }
    }
    return formatter.format(instant.toLocal());
  }

  static final _iso = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})[Tt ](\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{1,9}))?)?([Zz]|[+-]\d{2}:?\d{2})?$',
  );

  static ServerActivityStartTime? _parse(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    final match = _iso.firstMatch(text);
    if (match == null) return null;
    final year = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final day = int.parse(match[3]!);
    final hour = int.parse(match[4]!);
    final minute = int.parse(match[5]!);
    final second = int.parse(match[6] ?? '0');
    final fraction = (match[7] ?? '').padRight(6, '0').substring(0, 6);
    final microseconds = int.parse(fraction);
    final calendar = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
      microseconds ~/ 1000,
      microseconds % 1000,
    );
    // DateTime normalizes invalid dates and times; reject those API values.
    if (calendar.year != year ||
        calendar.month != month ||
        calendar.day != day ||
        calendar.hour != hour ||
        calendar.minute != minute ||
        calendar.second != second) {
      return null;
    }
    final offset = match[8];
    if (offset == null) {
      return ServerActivityStartTime._(calendar, null, null);
    }
    if (offset.toUpperCase() != 'Z') {
      final digits = offset.substring(1).replaceAll(':', '');
      if (int.parse(digits.substring(0, 2)) > 23 ||
          int.parse(digits.substring(2)) > 59) {
        return null;
      }
    }
    final instant = DateTime.tryParse(text.toUpperCase())?.toUtc();
    return instant == null
        ? null
        : ServerActivityStartTime._(calendar, instant, null);
  }
}
