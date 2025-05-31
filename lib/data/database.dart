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
        CREATE TABLE user_focusactivities(
          id TEXT PRIMARY KEY,
          title TEXT,
          description TEXT,
          iconName TEXT,
          weeklyGoal INTEGER,
          startDate TEXT,
          loggedTime INTEGER,
          status TEXT)
      ''');
      await db.execute('''
        CREATE TABLE visited_screens(
          screenId TEXT PRIMARY KEY
        );
      ''');  
    },
  );
}