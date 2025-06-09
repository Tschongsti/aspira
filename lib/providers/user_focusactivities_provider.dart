import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sqflite/sqflite.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';

import 'package:aspira/data/database.dart';

class UserFokusActivitiesNotifier extends StateNotifier<List<FokusTaetigkeit>> {
  UserFokusActivitiesNotifier() : super(const []);

  Future<void> loadFokusActivities() async {
    final db = await getDatabase();
    final data = await db.query('user_focusactivities');

    final fokusList = data.map((row) => FokusTaetigkeit.fromLocalMap(row)).toList();
    state = fokusList;
  }

  Future<void> addFokusTaetigkeit(FokusTaetigkeit fokus) async {
    final db = await getDatabase();
    await db.insert(
      'user_focusactivities',
      fokus.toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    state = [fokus, ...state];
  }

  Future<void> updateFokusTaetigkeit(FokusTaetigkeit updated) async {
    final db = await getDatabase();
    await db.update(
      'user_focusactivities',
      updated.toLocalMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );

    final index = state.indexWhere((item) => item.id == updated.id);
    if (index != -1) {
      final newList = [...state];
      newList[index] = updated;
      state = newList;
    }
  }

  Future<void> deleteFokusTaetigkeit(String id) async {
    final db = await getDatabase();
    await db.delete(
      'user_focusactivities',
      where: 'id = ?',
      whereArgs: [id],
    );
    state = [...state]..removeWhere((item) => item.id == id);
  }

  Future<void> insertAt(int index, FokusTaetigkeit fokus) async {
    final db = await getDatabase();

    await db.insert(
      'user_focusactivities',
      fokus.toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final newList = [...state];
    newList.insert(index, fokus);
    state = newList;
  }

  Future<void> clearAll() async {
    final db = await getDatabase();
    await db.delete('user_focusactivities');
    state = [];
  }
}

final userFokusActivitiesProvider =
    StateNotifierProvider<UserFokusActivitiesNotifier, List<FokusTaetigkeit>>(
  (ref) => UserFokusActivitiesNotifier(),
);
