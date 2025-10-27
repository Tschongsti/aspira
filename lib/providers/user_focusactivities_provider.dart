import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sqflite/sqflite.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/providers/auth_provider.dart';
import 'package:aspira/data/database.dart';

class UserFokusActivitiesNotifier extends StateNotifier<List<FokusTaetigkeit>> {
  UserFokusActivitiesNotifier(this.ref) : super(const []);

  final Ref ref;

  Future<void> ensureUserIdsForLegacyEntries() async {
    final uid = ref.read(firebaseUidProvider);
    if (uid == null) {
      debugPrint('⚠️ UID nicht verfügbar: kann Legacy-Migration nicht durchführen');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final flagKey = 'userIdMigrationDone_$uid';
      final alreadyMigrated = prefs.getBool(flagKey) ?? false;

      if (alreadyMigrated) {
        debugPrint('ℹ️ Migration bereits durchgeführt für UID: $uid');
        return;
      }

      final db = await getDatabase();
      final result = await db.rawUpdate(
        'UPDATE user_focusactivities SET userId = ? WHERE userId IS NULL OR userId = ""',
        [uid],
      );

      if (result > 0) {
        debugPrint('🔄 Legacy-Migration: $result FokusTätigkeiten mit userId=$uid aktualisiert');
      } else {
        debugPrint('ℹ️ Keine veralteten Einträge ohne userId gefunden');
      }

      await prefs.setBool(flagKey, true);
      debugPrint('✅ Migration-Flag gesetzt: $flagKey');

    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler bei Legacy-Migration: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
    
  Future<void> loadFokusActivities() async {
    try {
      final uid = ref.read(firebaseUidProvider);
      debugPrint('🧩 UID beim Laden: $uid');
      if (uid == null) {
        debugPrint('🛑 Kein UID vorhanden: keine Fokustätigkeiten geladen');
        return;
      }

      // 🧩 UID-basierte Nachmigration sicherstellen
      await ensureUserIdsForLegacyEntries();
            
      final db = await getDatabase();
      final data = await db.query(
        'user_focusactivities',
        where: 'userId = ?',
        whereArgs: [uid],  
      );

      final fokusList = data
        .map((row) => FokusTaetigkeit.fromLocalMap(row))
        .where((item) => 
          !item.isArchived &&
          item.status != TaskStatus.deleted)
        .toList();
      state = fokusList;
    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler beim Laden der Fokustätigkeiten: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> addFokusTaetigkeit(FokusTaetigkeit fokus) async {
    final previousState = [...state];

    try {
      final uid = ref.read(firebaseUidProvider);
      if (uid == null) {
        debugPrint('🛑 Kein Nutzer eingeloggt: Aktion abgebrochen');
        return;
      }

      final db = await getDatabase();
      debugPrint('[ADD] ${fokus.toLocalMap()}');
      await db.insert(
        'user_focusactivities',
        fokus.toLocalMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      state = [fokus, ...state];
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

      await db.transaction((txn) async {

        // 1) Aktuellen Stand holen (für korrektes Archiv)
        FokusTaetigkeit? current;
        final i = state.indexWhere((t) => t.id == updated.id);
        if (i != -1) {
          current = state[i];
        } else {
          final rows = await txn.query(
            'user_focusactivities',
            where: 'id = ?',
            whereArgs: [updated.id],
            limit: 1,
          );
          if (rows.isNotEmpty) current = FokusTaetigkeit.fromLocalMap(rows.first);
        }

        // 🔎 Mini-Sanity-Check #1 – direkt nach dem Laden des alten Stands
        debugPrint(
          '[updateFokusTaetigkeit] id=${updated.id} | '
          'OLD weeklyGoal=${current?.weeklyGoal.inMinutes}min | '
          'NEW weeklyGoal=${updated.weeklyGoal.inMinutes}min | '
          'versionGoal=$versionGoal'
        );

        // 2) Falls WeeklyGoal geändert → alte Version archivieren (alter Stand!)
        if (versionGoal && current != null) {
          final ts = DateTime.now().toIso8601String();
          final archived = current.copyWith(
            id: '${current.id}_$ts',
            isArchived: true,
            updatedAt: DateTime.now(),
            isDirty: true,
          );
          await txn.insert('user_focusactivities', archived.toLocalMap());
        }

        // 3) Aktuellen Datensatz updaten (mit neuen Feldern)
        final updatedWithMeta = updated.copyWith(
          updatedAt: DateTime.now(),
          isDirty: true,
        );
        await txn.update(
          'user_focusactivities',
          updatedWithMeta.toLocalMap(),
          where: 'id = ?',
          whereArgs: [updated.id],
        );

        // 4) State synchron halten
        if (i != -1) {
          final list = [...state];
          list[i] = updatedWithMeta;
          state = list;
        } else {
          state = [updatedWithMeta, ...state];
        }
      });

    } catch (e, st) {
      debugPrint('🛑 Fehler updateFokusTaetigkeit: $e');
      debugPrintStack(stackTrace: st);
      state = previousState;
    }
  }

  Future<void> deleteFokusTaetigkeit(FokusTaetigkeit deleted) async {
    final previousState = [...state];
    try {
      final db = await getDatabase();
           
      final deletedFokus = deleted.copyWith(
        status: TaskStatus.deleted,
        isDirty: true,
        updatedAt: DateTime.now(),
      );
      
      await db.update(
        'user_focusactivities',
        deletedFokus.toLocalMap(),
        where: 'id = ?',
        whereArgs: [deletedFokus.id],
      );

      state = [...state]..removeWhere((item) => item.id == deletedFokus.id);

    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler beim Löschen: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = previousState;
    }
  }

  Future<void> restoreFokusTaetigkeit(int index, FokusTaetigkeit restore) async {
    final previousState = [...state];
    
    try {
      final restored = restore.copyWith(
        status: TaskStatus.active,
        updatedAt: DateTime.now(),
        isDirty: true,
      );
            
      final db = await getDatabase();
      await db.update(
        'user_focusactivities',
        restored.toLocalMap(),
        where: 'id = ?',
        whereArgs: [restored.id],
      );

      final newList = [...state];
      newList.insert(index, restored);
      state = newList;
      debugPrint('✅ Fokus-Tätigkeit wiederhergestellt: ${restored.id}');
    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler beim Einfügen an Position: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = previousState;
    }
  }

  Future<void> clearAll() async {
    try {
      final db = await getDatabase();
      await db.delete('user_focusactivities');
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
  (ref) => UserFokusActivitiesNotifier(ref),
);
