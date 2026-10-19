import 'dart:convert';

import 'package:endurain/core/utils/private_storage_paths.dart';
import 'package:endurain/core/utils/sqlite_migration_runner.dart';
import 'package:sqflite/sqflite.dart';

import 'package:endurain/features/achievements/models/achievement_models.dart';
import 'package:endurain/features/achievements/repositories/achievement_store.dart';
import 'package:endurain/features/achievements/repositories/achievements_repository.dart';

class SqfliteAchievementStore implements AchievementStore {
  SqfliteAchievementStore({
    DatabaseFactory? databaseFactory,
    String? databasePath,
  }) : _factory = databaseFactory ?? databaseFactorySqflitePlugin,
       _path = databasePath;
  final DatabaseFactory _factory;
  final String? _path;
  Future<Database>? _opening;

  Future<Database> _open() => _opening ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final path =
        _path ??
        await privateDatabasePath(
          databaseFactory: _factory,
          fileName: 'achievements.db',
        );
    final migrations = SqliteMigrationRunner(
      migrations: {
        1: (db) async {
          await db.execute(
            'CREATE TABLE schema_version (id INTEGER PRIMARY KEY, version INTEGER NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE analyses (scope TEXT NOT NULL, activity_id INTEGER NOT NULL, payload TEXT NOT NULL, PRIMARY KEY (scope, activity_id))',
          );
          await db.execute(
            'CREATE TABLE scan_state (scope TEXT PRIMARY KEY, payload TEXT NOT NULL)',
          );
        },
      },
      recordVersion: (db, version) async {
        await db.insert('schema_version', {
          'id': 1,
          'version': version,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      },
    );
    return _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) => migrations.run(db, from: 0, to: version),
        onUpgrade: (db, from, to) => migrations.run(db, from: from, to: to),
      ),
    );
  }

  @override
  Future<List<AchievementAnalysis>> loadAnalyses(String scope) async {
    final db = await _open();
    final rows = await db.query(
      'analyses',
      where: 'scope = ?',
      whereArgs: [scope],
      orderBy: 'activity_id',
    );
    return List.unmodifiable(
      rows.map(
        (row) => _decodeAnalysis(
          jsonDecode(row['payload']! as String) as Map<String, dynamic>,
        ),
      ),
    );
  }

  @override
  Future<void> replaceAnalysis(
    String scope,
    AchievementAnalysis analysis, {
    AchievementScanState? checkpoint,
  }) async {
    final activity = analysis.activity;
    final measurements = [
      activity.distanceMeters,
      activity.durationSeconds,
      activity.elevationGainMeters,
    ];
    if (measurements.any((value) => value != null && !value.isFinite) ||
        analysis.candidates.any(
          (candidate) =>
              !candidate.value.isFinite ||
              (candidate.targetDistanceMeters != null &&
                  !candidate.targetDistanceMeters!.isFinite),
        )) {
      throw ArgumentError(
        'Achievement analyses must contain finite measurements.',
      );
    }
    final db = await _open();
    await db.transaction((txn) async {
      await txn.insert('analyses', {
        'scope': scope,
        'activity_id': analysis.activity.id,
        'payload': jsonEncode(_encodeAnalysis(analysis)),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      if (checkpoint != null) await _writeScanState(txn, scope, checkpoint);
    });
  }

  @override
  Future<AchievementScanState?> loadScanState(String scope) async {
    final db = await _open();
    final rows = await db.query(
      'scan_state',
      where: 'scope = ?',
      whereArgs: [scope],
    );
    if (rows.isEmpty) return null;
    final data =
        jsonDecode(rows.single['payload']! as String) as Map<String, dynamic>;
    return AchievementScanState(
      generation: data['generation'] as int,
      status: AchievementScanStatus.values.byName(data['status'] as String),
      inventoryIds: List<int>.unmodifiable(
        (data['inventory'] as List).cast<int>(),
      ),
      processedCount: data['processed'] as int,
      totalCount: data['total'] as int,
      usableTrackCount: data['usable'] as int,
      unavailableTrackCount: data['unavailable'] as int,
      failures: Map.unmodifiable(
        (data['failures'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(int.parse(key), value as String),
        ),
      ),
      skipped: Map.unmodifiable(
        (data['skipped'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            int.parse(key),
            List<String>.unmodifiable((value as List).cast<String>()),
          ),
        ),
      ),
      nextPage: data['nextPage'] as int,
      rebuildInProgress: data['rebuildInProgress'] as bool? ?? false,
      pendingRebuildIds:
          (data['pendingRebuildIds'] as List?)?.cast<int>() ?? const [],
      firstDayOfWeek: data['firstDayOfWeek'] as int?,
      lastSuccessfulAt: _parse(data['lastSuccessful']),
      error: data['error'] as String?,
    );
  }

  @override
  Future<void> saveScanState(String scope, AchievementScanState state) async =>
      _writeScanState(await _open(), scope, state);
  @override
  Future<void> completeInventory(
    String scope, {
    required Set<int> confirmedDeletedIds,
    required AchievementScanState state,
  }) async {
    if (state.status != AchievementScanStatus.complete ||
        state.failures.isNotEmpty ||
        state.processedCount != state.totalCount ||
        state.inventoryIds.toSet().length != state.totalCount ||
        state.inventoryIds.any(confirmedDeletedIds.contains)) {
      throw StateError(
        'Deletion requires a complete, successful inventory and separately confirmed absent IDs.',
      );
    }
    final db = await _open();
    await db.transaction((txn) async {
      for (final id in confirmedDeletedIds) {
        await txn.delete(
          'analyses',
          where: 'scope = ? AND activity_id = ?',
          whereArgs: [scope, id],
        );
      }
      await _writeScanState(txn, scope, state);
    });
  }

  @override
  Future<void> clear(String scope) async {
    final db = await _open();
    await db.transaction((txn) async {
      await txn.delete('analyses', where: 'scope = ?', whereArgs: [scope]);
      await txn.delete('scan_state', where: 'scope = ?', whereArgs: [scope]);
    });
  }

  Future<void> _writeScanState(
    DatabaseExecutor db,
    String scope,
    AchievementScanState state,
  ) async {
    final data = {
      'generation': state.generation,
      'status': state.status.name,
      'inventory': state.inventoryIds,
      'processed': state.processedCount,
      'total': state.totalCount,
      'usable': state.usableTrackCount,
      'unavailable': state.unavailableTrackCount,
      'failures': state.failures.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'skipped': state.skipped.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'nextPage': state.nextPage,
      'rebuildInProgress': state.rebuildInProgress,
      'pendingRebuildIds': state.pendingRebuildIds,
      'firstDayOfWeek': state.firstDayOfWeek,
      'lastSuccessful': _date(state.lastSuccessfulAt),
      'error': state.error,
    };
    await db.insert('scan_state', {
      'scope': scope,
      'payload': jsonEncode(data),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) await (await opening).close();
  }

  static String? _date(DateTime? date) => date?.toUtc().toIso8601String();
  static DateTime? _parse(dynamic value) =>
      value == null ? null : DateTime.parse(value as String).toUtc();
  static double? _number(dynamic value) => (value as num?)?.toDouble();

  static Map<String, Object?> _encodeAnalysis(AchievementAnalysis analysis) {
    final a = analysis.activity;
    return {
      'id': a.id,
      'sport': a.sportType,
      'fingerprint': a.fingerprint,
      'start': _date(a.startedAt),
      'distance': a.distanceMeters,
      'duration': a.durationSeconds,
      'elevation': a.elevationGainMeters,
      'source': a.distanceSource.name,
      'version': analysis.calculationVersion,
      'candidates': [
        for (final c in analysis.candidates)
          {
            'activity': c.activityId,
            'sport': c.sportType,
            'metric': c.metric.name,
            'value': c.value,
            'start': _date(c.startedAt),
            'target': c.targetDistanceMeters,
            'effortStart': _date(c.effortStart),
            'effortEnd': _date(c.effortEnd),
            'source': c.distanceSource.name,
          },
      ],
    };
  }

  static AchievementAnalysis _decodeAnalysis(Map<String, dynamic> data) =>
      AchievementAnalysis(
        activity: AchievementActivity(
          id: data['id'] as int,
          sportType: data['sport'] as int,
          fingerprint: data['fingerprint'] as String,
          startedAt: _parse(data['start']),
          distanceMeters: _number(data['distance']),
          durationSeconds: _number(data['duration']),
          elevationGainMeters: _number(data['elevation']),
          distanceSource: AchievementDistanceSource.values.byName(
            data['source'] as String,
          ),
        ),
        candidates: List.unmodifiable(
          (data['candidates'] as List).map((raw) {
            final c = raw as Map<String, dynamic>;
            return AchievementCandidate(
              activityId: c['activity'] as int,
              sportType: c['sport'] as int,
              metric: AchievementMetric.values.byName(c['metric'] as String),
              value: _number(c['value'])!,
              startedAt: _parse(c['start']),
              targetDistanceMeters: _number(c['target']),
              effortStart: _parse(c['effortStart']),
              effortEnd: _parse(c['effortEnd']),
              distanceSource: AchievementDistanceSource.values.byName(
                c['source'] as String,
              ),
            );
          }),
        ),
        calculationVersion: data['version'] as int,
      );
}
