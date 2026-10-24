import 'package:endurain/features/server_activities/models/server_activity_start_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  final display = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

  test(
    'activity wall clock time takes precedence without another conversion',
    () {
      final start = ServerActivityStartTime.fromApi(
        timezoneApplied: '2026-10-18T17:15:00',
        fallback: '2026-10-18T15:15:00',
      )!;
      expect(start.isAbsolute, isFalse);
      expect(start.instantUtc, isNull);
      expect(start.format(display), '2026-10-18 17:15:00.000');
    },
  );

  test('wall clock fields survive device daylight saving gaps', () {
    final start = ServerActivityStartTime.fromApi(
      timezoneApplied: '2026-03-29T02:30:00',
    )!;
    expect(start.format(display), '2026-03-29 02:30:00.000');
  });

  test('naive server fallback is also a wall clock value', () {
    final start = ServerActivityStartTime.fromApi(
      fallback: ' 2026-10-18 17:15:00.123456 ',
    )!;
    expect(start.instantUtc, isNull);
    expect(start.format(display), '2026-10-18 17:15:00.123');
  });

  for (final value in [
    '2026-10-18T15:15:00Z',
    '2026-10-18T17:15:00+02:00',
    '2026-10-18T17:15:00+0200',
    '2026-10-18T10:15:00-05:00',
  ]) {
    test('explicit offset identifies the instant: $value', () {
      final start = ServerActivityStartTime.fromApi(fallback: value)!;
      final instant = DateTime.utc(2026, 10, 18, 15, 15);
      expect(start.isAbsolute, isTrue);
      expect(start.instantUtc, instant);
      expect(start.format(display), display.format(instant.toLocal()));
    });
  }

  for (final value in <Object?>[
    null,
    '',
    'invalid',
    1792336500,
    '2026-02-30T17:15:00',
    '2026-10-18T25:15:00',
    '2026-10-18T17:61:00',
    '2026-10-18T17:15:00+02:61',
    '2026-10-18T17:15:00+24:00',
  ]) {
    test('missing or invalid preferred value falls back: $value', () {
      final start = ServerActivityStartTime.fromApi(
        timezoneApplied: value,
        fallback: '2026-10-18T17:15:00',
      )!;
      expect(start.format(display), '2026-10-18 17:15:00.000');
      expect(ServerActivityStartTime.fromApi(fallback: value), isNull);
    });
  }

  test('missing API fields remain missing', () {
    expect(ServerActivityStartTime.fromApi(), isNull);
  });

  test('absolute start time renders in the recorded timezone', () {
    final start = ServerActivityStartTime.fromApi(
      fallback: '2026-10-18T15:15:35Z',
      timezone: 'America/New_York',
    )!;
    expect(start.isAbsolute, isTrue);
    expect(start.format(display), '2026-10-18 11:15:35.000');
  });

  test('recorded timezone applies its DST rules, not a fixed offset', () {
    final summer = ServerActivityStartTime.fromApi(
      fallback: '2026-07-18T15:15:35Z',
      timezone: 'America/New_York',
    )!;
    final winter = ServerActivityStartTime.fromApi(
      fallback: '2026-01-18T15:15:35Z',
      timezone: 'America/New_York',
    )!;
    expect(summer.format(display), '2026-07-18 11:15:35.000');
    expect(winter.format(display), '2026-01-18 10:15:35.000');
  });

  test('offset-free wall clock ignores the recorded timezone', () {
    final start = ServerActivityStartTime.fromApi(
      fallback: '2026-10-18T15:15:35',
      timezone: 'America/New_York',
    )!;
    expect(start.isAbsolute, isFalse);
    expect(start.format(display), '2026-10-18 15:15:35.000');
  });

  for (final value in <Object?>[null, '', '  ', 4711, 'Not/AZone']) {
    test('missing or invalid recorded timezone falls back to device local: '
        '$value', () {
      final instant = DateTime.utc(2026, 10, 18, 15, 15, 35);
      final start = ServerActivityStartTime.fromApi(
        fallback: '2026-10-18T15:15:35Z',
        timezone: value,
      )!;
      expect(start.format(display), display.format(instant.toLocal()));
    });
  }
}
