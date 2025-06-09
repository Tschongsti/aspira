import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sqflite/sqflite.dart';

import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/data/database.dart';

class UserFokusActivitiesNotifier extends StateNotifier<List<FokusTaetigkeit>> {
  UserFokusActivitiesNotifier() : super(const []);

  Future<void> loadFokusActivities() async {
    try {
      final db = await getDatabase();
      final data = await db.query('user_focusactivities');

      final fokusList = data
        .map((row) => FokusTaetigkeit.fromLocalMap(row))
        .where((item) => item.status == Status.active && !item.isArchived)
        .toList();
      state = fokusList;
    } catch (e, st) {
      debugPrint('🛑 Fehler beim Laden der Fokustätigkeiten: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> addFokusTaetigkeit(FokusTaetigkeit fokus) async {
    final previousState = [...state];
    try {
      final db = await getDatabase();
      await db.insert(
        'user_focusactivities',
        fokus.toLocalMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      state = [fokus, ...state];
    } catch (e, st) {
      debugPrint('🛑 Fehler beim Hinzufügen: $e');
      debugPrintStack(stackTrace: st);
      state = previousState;
    }
  }

  Future<void> updateFokusTaetigkeit(FokusTaetigkeit updated, {bool versionGoal = false}) async {
    final previousState = [...state];

    try {
      final db = await getDatabase();

      if (versionGoal) {
        final timestamp = DateTime.now().toIso8601String();
        final archived = updated.copyWith(
          id: '${updated.id}_$timestamp',
          isArchived: true,
          updatedAt: DateTime.now(),
          isDirty: true,
        );

        await db.insert('user_focusactivities', archived.toLocalMap());
        debugPrint('📦 Alte Version archiviert: ${archived.id}');
      }

      final updatedWithMeta = updated.copyWith(
        updatedAt: DateTime.now(),
        isDirty: true,
      );

      await db.update(
        'user_focusactivities',
        updatedWithMeta.toLocalMap(),
        where: 'id = ?',
        whereArgs: [updated.id],
      );

      final index = state.indexWhere((item) => item.id == updated.id);
      if (index != -1) {
        final newList = [...state];
        newList[index] = updatedWithMeta;
        state = newList;
      }

    } catch (e, st) {
      debugPrint('🛑 Fehler beim Update: $e');
      debugPrintStack(stackTrace: st);
      state = previousState;
    }
  }

  Future<void> deleteFokusTaetigkeit(String id) async {
    final previousState = [...state];
    try {
      final db = await getDatabase();
      await db.delete(
        'user_focusactivities',
        where: 'id = ?',
        whereArgs: [id],
      );
      state = [...state]..removeWhere((item) => item.id == id);
    } catch (e, st) {
      debugPrint('🛑 Fehler beim Löschen: $e');
      debugPrintStack(stackTrace: st);
      state = previousState;
    }
  }

  Future<void> insertAt(int index, FokusTaetigkeit fokus) async {
    final previousState = [...state];
    try {
      final db = await getDatabase();
      await db.insert(
        'user_focusactivities',
        fokus.toLocalMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final newList = [...state];
      newList.insert(index, fokus);
      state = newList;
    } catch (e, st) {
      debugPrint('🛑 Fehler beim Einfügen an Position: $e');
      debugPrintStack(stackTrace: st);
      state = previousState;
    }
  }

  Future<void> clearAll() async {
    try {
      final db = await getDatabase();
      await db.delete('user_focusactivities');
      state = [];
    } catch (e, st) {
      debugPrint('🛑 Fehler beim Leeren: $e');
      debugPrintStack(stackTrace: st);
    }
  }
}

// Provider zur Anzeige inaktiver Fokustätigkeiten
final showInactiveProvider = StateProvider<bool>((ref) => false);

// Hauptprovider
final userFokusActivitiesProvider =
    StateNotifierProvider<UserFokusActivitiesNotifier, List<FokusTaetigkeit>>(
  (ref) => UserFokusActivitiesNotifier(),
);
