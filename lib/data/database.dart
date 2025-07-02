import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart'as sql;
import 'package:sqflite/sqlite_api.dart';

const _dbName = 'aspira.db';
const _dbVersion = 3;

Future<Database> getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final dbFullpath = path.join(dbPath, _dbName);
  debugPrint('📁 Öffne Datenbank: $dbFullpath');

  return sql.openDatabase(
    dbFullpath,
    version: _dbVersion,
    onCreate: _createDb,
    onUpgrade: _runMigrations,
    onDowngrade: sql.onDatabaseDowngradeDelete, // ⚠️ Dev-Setting, siehe Kommentar unten
  );
}

Future<void> _createDb(Database db, int version) async {
  debugPrint('📦 Erstelle neue Datenbank-Version $version');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS user_focusactivities(
      id TEXT PRIMARY KEY,
      userId TEXT,
      title TEXT,
      description TEXT,
      iconCodePoint INTEGER,
      iconFontFamily TEXT,
      weeklyGoal INTEGER,
      startDate TEXT,
      loggedTime INTEGER,
      isArchived INTEGER,
      status TEXT,
      updatedAt TEXT,
      isDirty INTEGER,
      type TEXT
    );
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS execution_entries(
      id TEXT PRIMARY KEY,
      taskId TEXT,
      start TEXT,
      end TEXT,
      status TEXT,
      isDirty INTEGER,
      updatedAt TEXT,
      isArchived INTEGER
    );
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS user_profile (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL,
      displayName TEXT,
      photoUrl TEXT,
      isDirty INTEGER NOT NULL,
      updatedAt TEXT NOT NULL
    );
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS visited_screens(
      screenId TEXT PRIMARY KEY
    );
  ''');  
}

Future<void> _runMigrations(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    debugPrint('🛠️ Migration auf Version 2 gestartet');
    await db.execute('ALTER TABLE user_focusactivities ADD COLUMN userId TEXT;');
    debugPrint('🧱 Spalte userId ergänzt');
    debugPrint('✅ Migration auf Version 2 abgeschlossen');
  }
 
  if (oldVersion < 3) {
    debugPrint('🛠️ Migration auf Version 3 gestartet');
    await db.execute('ALTER TABLE execution_entries ADD COLUMN status TEXT;');
    debugPrint('🧱 Spalte status in execution_entries ergänzt');
    debugPrint('✅ Migration auf Version 3 abgeschlossen');
  }

  if (oldVersion >= newVersion) {
    debugPrint('📭 Keine Migration notwendig');
  }
}