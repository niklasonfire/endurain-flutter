import 'dart:convert';

import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/core/utils/json_parsing.dart';
import 'package:endurain/core/utils/private_storage_paths.dart';
import 'package:endurain/core/utils/sqlite_migration_runner.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite-backed [OfflineCacheStore] in its own `offline_cache.db` file.
///
/// Inject a custom databaseFactory and databasePath in tests:
/// ```dart
/// SqfliteOfflineCacheStore(
///   databaseFactory: databaseFactoryFfi,
///   databasePath: inMemoryDatabasePath,
/// )
/// ```
class SqfliteOfflineCacheStore implements OfflineCacheStore {
  SqfliteOfflineCacheStore({
    DatabaseFactory? databaseFactory,
    String? databasePath,
  }) : _factory = databaseFactory ?? _platformFactory(),
       _path = databasePath;

  static const int _schemaVersion = 1;
  static const String _dbFileName = 'offline_cache.db';
  static const String _tableVersion = 'schema_version';
  static const String _tableEntry = 'offline_cache_entry';

  final DatabaseFactory _factory;
  final String? _path;
  Database? _db;

  /// Ordered schema migrations keyed by the version they upgrade the
  /// database **to**; see [SqliteMigrationRunner] for the rules. Never edit
  /// a shipped migration — only append new ones.
  late final SqliteMigrationRunner _migrationRunner = SqliteMigrationRunner(
    migrations: {1: _migrateToV1},
    recordVersion: _recordSchemaVersion,
  );

  static DatabaseFactory _platformFactory() => databaseFactorySqflitePlugin;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final path =
        _path ??
        await privateDatabasePath(
          databaseFactory: _factory,
          fileName: _dbFileName,
        );
    _db = await _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _schemaVersion,
        onCreate: (db, version) async =>
            _migrationRunner.run(db, from: 0, to: version),
        onUpgrade: (db, oldVersion, newVersion) async =>
            _migrationRunner.run(db, from: oldVersion, to: newVersion),
      ),
    );
    return _db!;
  }

  Future<void> _recordSchemaVersion(Database db, int version) async {
    await db.delete(_tableVersion);
    await db.insert(_tableVersion, {'version': version});
  }

  /// Initial schema (version 1): the schema-version bookkeeping table and the
  /// raw-payload table. Every entry is identity-qualified through both its
  /// composite key and the separate `profile_id` column, so a per-identity
  /// wipe (`clearForProfile`) never has to parse keys.
  Future<void> _migrateToV1(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableVersion (
        version INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $_tableEntry (
        cache_key   TEXT PRIMARY KEY,
        profile_id  TEXT NOT NULL,
        payload     TEXT NOT NULL,
        fetched_at  TEXT NOT NULL
      )
    ''');
  }

  @override
  Future<OfflineCacheEntry?> read({
    required String profileId,
    required String concept,
    required String query,
  }) async {
    final db = await _open();
    final rows = await db.query(
      _tableEntry,
      where: 'cache_key = ?',
      whereArgs: [
        offlineCacheKey(profileId: profileId, concept: concept, query: query),
      ],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return OfflineCacheEntry(
      profileId: row['profile_id'] as String,
      concept: concept,
      query: query,
      payload: jsonDecode(row['payload'] as String),
      fetchedAt: jsonDateTime(row['fetched_at'])!,
    );
  }

  @override
  Future<void> write(OfflineCacheEntry entry) async {
    final db = await _open();
    await db.insert(_tableEntry, {
      'cache_key': offlineCacheKey(
        profileId: entry.profileId,
        concept: entry.concept,
        query: entry.query,
      ),
      'profile_id': entry.profileId,
      'payload': jsonEncode(entry.payload),
      'fetched_at': entry.fetchedAt.toUtcIso8601(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> clearForProfile(String profileId) async {
    final db = await _open();
    return db.delete(
      _tableEntry,
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
  }

  @override
  Future<void> clearAll() async {
    final db = await _open();
    await db.delete(_tableEntry);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
