import 'dart:async';
import 'dart:isolate';

import 'package:endurain/core/models/app_exception.dart';

import 'package:endurain/shared/state/safe_notifier.dart';
import 'package:endurain/features/achievements/models/achievement_models.dart';
import 'package:endurain/features/achievements/repositories/achievements_repository.dart';
import 'package:endurain/features/achievements/services/achievement_calculator.dart';
import 'package:endurain/features/achievements/services/achievement_scan_service.dart';

class AchievementsController extends SafeNotifier {
  AchievementsController({required AchievementScanService scanService})
    : _scan = scanService {
    _scan.addListener(_changed);
  }
  final AchievementScanService _scan;
  int? _sport, _year;
  int? get selectedSport => _sport;
  int? get selectedYear => _year;
  AchievementSnapshot? get snapshot => _scan.snapshot;
  AchievementScanState? get scanState => snapshot?.scanState;
  bool get isGuest => _scan.isGuest;
  bool get isLoading => _scan.isLoading || _deriving;
  bool get isScanning => _scan.isScanning;
  AppException? get error => _scan.error ?? _deriveError;
  List<int> get availableSports =>
      (snapshot?.analyses.map((a) => a.activity.sportType).toSet().toList() ??
            [])
        ..sort();
  List<int> get availableYears =>
      (snapshot?.analyses
                .map((a) => a.activity.startedAt?.toUtc().year)
                .whereType<int>()
                .toSet()
                .toList() ??
            [])
        ..sort((a, b) => b.compareTo(a));
  List<AchievementRecord> _records = const [];
  List<AchievementRecord> get records => _records;
  bool _deriving = false;
  AppException? _deriveError;
  int _derivationGeneration = 0;
  AchievementSnapshot? _derivedSnapshot;
  int? _derivedSport, _derivedYear;
  Future<void>? _derivation;

  Future<void> _derive() {
    final current = snapshot;
    if (identical(current, _derivedSnapshot) &&
        _sport == _derivedSport &&
        _year == _derivedYear &&
        _derivation != null) {
      return _derivation!;
    }
    _derivedSnapshot = current;
    _derivedSport = _sport;
    _derivedYear = _year;
    final generation = ++_derivationGeneration;
    return _derivation = _deriveRecords(current, _sport, _year, generation);
  }

  Future<void> _deriveRecords(
    AchievementSnapshot? current,
    int? sport,
    int? year,
    int generation,
  ) async {
    _deriveError = null;
    if (current == null || year == null) {
      _records = List.unmodifiable(
        (current?.records ?? const <AchievementRecord>[]).where(
          (r) => sport == null || r.winner.sportType == sport,
        ),
      );
      _deriving = false;
      notify();
      return;
    }
    _deriving = true;
    // Never display records from the previous year under a newly selected year.
    _records = const [];
    notify();
    try {
      final records = await Isolate.run(
        () => _recordsForYear(current, sport, year),
      );
      if (isDisposed || generation != _derivationGeneration) return;
      _records = records;
    } catch (error) {
      if (!isDisposed && generation == _derivationGeneration) {
        _deriveError = AppException(
          AppErrorCode.achievementCalculationFailed,
          cause: error,
        );
      }
    } finally {
      if (!isDisposed && generation == _derivationGeneration) {
        _deriving = false;
        notify();
      }
    }
  }

  Future<void> initialize() async {
    if (_scan.snapshot == null) await _scan.initialize();
    await _derive();
  }

  Future<void> refresh() async {
    await _scan.scan();
    await _derive();
  }

  Future<void> rebuild() async {
    await _scan.scan(rebuild: true);
    await _derive();
  }

  void cancel() => unawaited(_scan.cancel());
  Future<void> setSport(int? sport) async {
    _sport = sport;
    await _derive();
  }

  Future<void> setYear(int? year) async {
    _year = year;
    await _derive();
  }

  void _changed() {
    if (snapshot == null) {
      _sport = null;
      _year = null;
    } else {
      if (_sport != null && !availableSports.contains(_sport)) _sport = null;
      if (_year != null && !availableYears.contains(_year)) _year = null;
    }
    unawaited(_derive());
    notify();
  }

  @override
  void dispose() {
    _derivationGeneration++;
    _scan.removeListener(_changed);
    super.dispose();
  }
}

List<AchievementRecord> _recordsForYear(
  AchievementSnapshot snapshot,
  int? sport,
  int year,
) {
  return const AchievementCalculator().selectRecords(
    snapshot.analyses,
    year: year,
    sportType: sport,
    firstDayOfWeek: snapshot.scanState?.firstDayOfWeek,
  );
}
