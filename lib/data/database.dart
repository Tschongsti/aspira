import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart'as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final dbFullpath = path.join(dbPath, 'aspira.db');

  return sql.openDatabase(
    dbFullpath,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_focusactivities(
          id TEXT PRIMARY KEY,
          title TEXT,
          description TEXT,
          iconName TEXT,
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
        CREATE TABLE IF NOT EXISTS visited_screens(
          screenId TEXT PRIMARY KEY
        );
      ''');  
    },
  );
}