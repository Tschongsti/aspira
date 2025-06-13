import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sqflite/sqflite.dart';

import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/providers/current_user_provider.dart';
import 'package:aspira/data/database.dart';

class UserFokusActivitiesNotifier extends StateNotifier<List<FokusTaetigkeit>> {
  final String userId;

  UserFokusActivitiesNotifier({required this.userId}) : super(const []);

  Future<void> loadFokusActivities() async {
    try {
      final db = await getDatabase();
      
      if (userId == 'unknown') {
        debugPrint('⚠️ Kein gültiger Nutzer – keine Fokustätigkeiten geladen.');
        state = [];
        return;
      }

      final data = await db.query(
        'user_focusactivities',
        where: '''
          userId = ?
          AND (isArchived IS NULL OR isArchived = 0)
          AND status != ?
        ''',
        whereArgs: [userId, Status.deleted.name],
      );

      final fokusList = data
        .map((row) {
          debugPrint('🧱 Zeile aus DB: $row');
          return FokusTaetigkeit.fromLocalMap(row);
        })
        .toList();
      state = fokusList;
    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler beim Laden der Fokustätigkeiten: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = [];
    }
  }

  Future<void> addFokusTaetigkeit(FokusTaetigkeit fokus) async {
    final previousState = [...state];
    try {
      final db = await getDatabase();
      final fokusWithUser = fokus.copyWith(userId: userId);
      await db.insert(
        'user_focusactivities',
        fokusWithUser.toLocalMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      state = [fokusWithUser, ...state];
    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler beim Hinzufügen: $error');
      debugPrintStack(stackTrace: stackTrace);
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
          userId: userId,
          isArchived: true,
          updatedAt: DateTime.now(),
          isDirty: true,
        );

        await db.insert('user_focusactivities', archived.toLocalMap());
        debugPrint('📦 Alte Version archiviert: ${archived.id}');
      }

      final updatedWithMeta = updated.copyWith(
        userId: userId,
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

    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler beim Update: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = previousState;
    }
  }

  Future<void> deleteFokusTaetigkeit(String id) async {
    final previousState = [...state];
    try {
      final db = await getDatabase();
      await db.delete(
        'user_focusactivities',
        where: 'id = ? AND userId = ?',
        whereArgs: [id, userId],
      );
      state = [...state]..removeWhere((item) => item.id == id);
    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler beim Löschen: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = previousState;
    }
  }

  Future<void> insertAt(int index, FokusTaetigkeit fokus) async {
    final previousState = [...state];
    try {
      final db = await getDatabase();
      final fokusWithUser = fokus.copyWith(userId: userId);
      await db.insert(
        'user_focusactivities',
        fokusWithUser.toLocalMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final newList = [...state];
      newList.insert(index, fokusWithUser);
      state = newList;
    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler beim Einfügen an Position: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = previousState;
    }
  }

  Future<void> clearAll() async {
    try {
      final db = await getDatabase();
      await db.delete(
        'user_focusactivities',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      state = [];
    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler beim Leeren: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

// Provider zur Anzeige inaktiver Fokustätigkeiten
final showInactiveProvider = StateProvider<bool>((ref) => false);

// Hauptprovider
final userFokusActivitiesProvider =
    StateNotifierProvider<UserFokusActivitiesNotifier, List<FokusTaetigkeit>>(
  (ref) {
    final userId = ref.watch(currentUserIdProvider);
    return UserFokusActivitiesNotifier(userId: userId);
  },
);
