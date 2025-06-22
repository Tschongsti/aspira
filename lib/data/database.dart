import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart'as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:aspira/providers/auth_provider.dart';

const _dbName = 'aspira.db';
const _dbVersion = 2;

Future<Database> getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final dbFullpath = path.join(dbPath, _dbName);

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

    final container = ProviderContainer();
    final uid = container.read(firebaseUidProvider);
    container.dispose();

    if (uid != null) {
      await db.execute(
        'UPDATE user_focusactivities SET userId = ? WHERE userId IS NULL',
        [uid],
      );
      debugPrint('🔄 Bestehende FokusTätigkeiten mit userId: $uid aktualisiert');
    } else {
      debugPrint('⚠️ UID bei Migration nicht verfügbar – userId bleibt leer');
    }

    debugPrint('✅ Migration auf Version 2 abgeschlossen');
  }
}