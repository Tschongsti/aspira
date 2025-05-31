import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart'as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, 'focusactivities.db'),
      onCreate: (db, version) {
        return db.execute('''
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
      },
      version: 1,
    );
  return db;
}

class UserFokusActivitiesNotifier extends StateNotifier<List<FokusTaetigkeit>> {
  UserFokusActivitiesNotifier() : super(const []);

  Future<void> loadFocusActivities() async {
    final db = await _getDatabase();
    final data = await db.query('user_focusactivities');
    final focusactivities = data.map(
      (row) => FokusTaetigkeit(
        id: row['id'] as String,
        title: row['title'] as String,
        description: row['description'] as String,
        iconName: IconName.values.byName(row['iconName'] as String),
        weeklyGoal: Duration(minutes: row['weeklyGoal'] as int),
        startDate: DateTime.parse(row['startDate'] as String),
        loggedTime: Duration(minutes: row['loggedTime'] as int),
        status: Status.values.byName(row['status'] as String),
      ),
    ).toList();

    state = focusactivities;
  }

  void addFokusTaetigkeit(FokusTaetigkeit fokus) async {   
    
    final db = await _getDatabase();
    await db.insert('user_focusactivities', {
      'id': fokus.id,
      'title': fokus.title,
      'description': fokus.description,
      'iconName': fokus.iconName.name,
      'weeklyGoal': fokus.weeklyGoal.inMinutes,
      'startDate': fokus.startDate.toIso8601String(),
      'loggedTime': fokus.loggedTime.inMinutes,
      'status': fokus.status.name,
    });
    
    state = [fokus, ...state]; // new FokusTätigkeit is always at the start of the list
  }

  void remove(FokusTaetigkeit fokus) async {
    
    final db = await _getDatabase();
    await db.delete(
      'user_focusactivities',
      where: 'id = ?',
      whereArgs: [fokus.id],
    );
    
    state = [...state]..remove(fokus);
  }

  void insertAt(int index, FokusTaetigkeit fokus) async {
    
    final db = await _getDatabase();
    await db.insert(
      'user_focusactivities',
      {
        'id': fokus.id,
        'title': fokus.title,
        'description': fokus.description,
        'iconName': fokus.iconName.name,
        'weeklyGoal': fokus.weeklyGoal.inMinutes,
        'startDate': fokus.startDate.toIso8601String(),
        'loggedTime': fokus.loggedTime.inMinutes,
        'status': fokus.status.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );    
    
    final newList = [...state];
    newList.insert(index, fokus);
    state = newList;
  }
}

final userFokusActivitiesProvider = StateNotifierProvider<UserFokusActivitiesNotifier, List <FokusTaetigkeit>>(
  (ref) => UserFokusActivitiesNotifier(),
);