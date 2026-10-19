import 'package:intl/intl.dart';

/// An activity's displayed start time, which can be either a wall clock time
/// already converted by Endurain or an ISO timestamp with an explicit offset.
///
/// Offset-free API values do not identify an instant. In particular, they must
/// never gain a `Z` suffix or be converted into the device's time zone again.
class ServerActivityStartTime {
  const ServerActivityStartTime._(this._calendarFields, this.instantUtc);

  // UTC is only a calendar carrier here, avoiding device DST normalization of
  // wall clock fields. For naive input it does NOT represent an actual instant.
  final DateTime _calendarFields;

  /// The actual instant, available only when the input specified its offset.
  final DateTime? instantUtc;

  bool get isAbsolute => instantUtc != null;

  /// Matches the web client's preference for the activity's local start time.
  /// Malformed preferred values fall back to the other API field.
  static ServerActivityStartTime? fromApi({
    Object? timezoneApplied,
    Object? fallback,
  }) => _parse(timezoneApplied) ?? _parse(fallback);

  /// Formats wall clock fields unchanged; absolute timestamps use device time.
  String format(DateFormat formatter) =>
      formatter.format(instantUtc?.toLocal() ?? _calendarFields);

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
    if (offset == null) return ServerActivityStartTime._(calendar, null);
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
        : ServerActivityStartTime._(calendar, instant);
  }
}
