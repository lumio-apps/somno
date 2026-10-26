import 'package:sqflite/sqflite.dart';

import 'models.dart';

class SessionDb {
  Future<Database>? _opening;

  Future<Database> get _database => _opening ??= _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      '$dir/somno.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE sessions ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'start_ms INTEGER NOT NULL UNIQUE, '
          'end_ms INTEGER NOT NULL, '
          'source INTEGER NOT NULL DEFAULT 0)',
        );
      },
    );
  }

  SleepSession _fromRow(Map<String, Object?> row) {
    return SleepSession(
      id: row['id'] as int,
      startMs: row['start_ms'] as int,
      endMs: row['end_ms'] as int,
      source: row['source'] as int,
    );
  }

  Map<String, Object?> _toRow(SleepSession s) {
    return <String, Object?>{
      'start_ms': s.startMs,
      'end_ms': s.endMs,
      'source': s.source,
    };
  }

  /// All sessions, newest wake-up first.
  Future<List<SleepSession>> all() async {
    final db = await _database;
    final rows = await db.query('sessions', orderBy: 'end_ms DESC');
    return rows.map(_fromRow).toList();
  }

  Future<void> insert(SleepSession s) async {
    final db = await _database;
    await db.insert(
      'sessions',
      _toRow(s),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> update(SleepSession s) async {
    final db = await _database;
    await db.update(
      'sessions',
      _toRow(s),
      where: 'id = ?',
      whereArgs: <Object?>[s.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete('sessions', where: 'id = ?', whereArgs: <Object?>[id]);
  }
}
