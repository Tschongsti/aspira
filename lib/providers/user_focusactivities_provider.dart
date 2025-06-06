import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sqflite/sqlite_api.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/data/database.dart';
import 'package:aspira/utils/get_current_user.dart';


class UserFokusActivitiesNotifier extends StateNotifier<List<FokusTaetigkeit>> {
  UserFokusActivitiesNotifier() : super(const []);

  CollectionReference<Map<String, dynamic>> _getFokusRef() {
    final user = getCurrentUserOrThrow();
    return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('fokus_activities');
  }

  Future<void> loadFokusActivities(BuildContext context) async {
    try {
      
      // Firestore lesen
      final snapshot = await _getFokusRef().get();

      final fokusActivities = snapshot.docs
        .where((doc) => !doc.id.contains('_'))
        .map((doc) => FokusTaetigkeit.fromMap(doc.data()))
        .toList();
            
      // 2. Lokale DB aktualisieren
      final db = await getDatabase();
      await db.delete('user_focusactivities'); // clear cache

      for (final fokus in fokusActivities) {
        await db.insert('user_focusactivities', fokus.toLocalMap());
      }
      state = fokusActivities;
    } catch (error, stackTrace) {
      debugPrint('Fehler loadFokusActivities: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Laden der Fokustätigkeiten')),
        );
      }
    }
  }

  Future<void> addFokusTaetigkeit(FokusTaetigkeit fokus, BuildContext context) async {   
    final previousState = [...state];
    state = [fokus, ...state]; // new FokusTätigkeit is always at the start of the list
    
    // Speicherung in Firebase
    try {
      final fokusDoc = _getFokusRef().doc(fokus.id);

      await fokusDoc.set(fokus.toFirebaseMap());
      debugPrint('addFokusTaetigkeit Firestore gespeichert: ${fokus.toFirebaseMap()}');

      // lokale Speicherung
      final db = await getDatabase();
      await db.insert('user_focusactivities', fokus.toLocalMap());
      debugPrint('addFokusTaetigkeit Lokal gespeichert: ${fokus.id}');

    } catch (error, stack) {
      debugPrint('Fehler addFokusTaetigkeit: $error');
      debugPrintStack(stackTrace: stack);

      state = previousState;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hinzufügen fehlgeschlagen. Bitte versuche es noch einmal.')),
        );
      }
    }
  }

  Future<void> updateFokusTaetigkeit(FokusTaetigkeit updated, {bool versionGoal = false}) async {
    final previousState = [...state];

    try {
      // Alte Version aus dem State holen (für Versionierung wichtig)
      final old = state.firstWhere((item) => item.id == updated.id);
      
      // 1. Falls versioniert werden soll → alte Version archivieren
      if (versionGoal) {
        final timestamp = DateTime.now().toLocal().toIso8601String();
        final versioned = FokusTaetigkeit(
          id: '${old.id}_$timestamp',
          title: old.title,
          description: old.description,
          iconName: old.iconName,
          weeklyGoal: old.weeklyGoal,
          startDate: old.startDate,
          loggedTime: old.loggedTime,
          status: old.status,
        );

        final archiveDoc = _getFokusRef().doc(versioned.id);

        await archiveDoc.set(versioned.toFirebaseMap());
      }

      // 2. Firestore überschreiben
      final fokusDoc = _getFokusRef().doc(updated.id);

      await fokusDoc.set(updated.toFirebaseMap());

      // 3. SQLite überschreiben
      final db = await getDatabase();
      await db.update(
        'user_focusactivities',
        updated.toLocalMap(),
        where: 'id = ?',
        whereArgs: [updated.id],
      );

      // 4. State aktualisieren
      final index = state.indexWhere((item) => item.id == updated.id);
      if (index != -1) {
        final newList = [...state];
        newList[index] = updated;
        state = newList;
      }

    } catch (error, stackTrace) {
      debugPrint('Fehler updateFokusTaetigkeit: $error');
      debugPrintStack(stackTrace: stackTrace);

      // Fallback
      state = previousState;
    }
  }

  void deleteFokustaetigkeit(FokusTaetigkeit fokus, BuildContext context) async { 
    // lokaler State
    final previousState = [...state];
    
    try{
      final db = await getDatabase();

      if (fokus.loggedTime == Duration.zero) {
        // 1. Hard delete in Firebase
        await _getFokusRef().doc(fokus.id).delete();

        // 2. Hard delete in SQLite
        await db.delete(
          'user_focusactivities',
          where: 'id = ?',
          whereArgs: [fokus.id],
        );

        // 3. Aus dem lokalen State entfernen
        state = [...state]..remove(fokus);
      } else {
        // Soft delete
        final updated = FokusTaetigkeit(
          id: fokus.id,
          title: fokus.title,
          description: fokus.description,
          iconName: fokus.iconName,
          weeklyGoal: fokus.weeklyGoal,
          startDate: fokus.startDate,
          loggedTime: fokus.loggedTime,
          status: Status.deleted,
        );

        await _getFokusRef().doc(fokus.id).set(updated.toFirebaseMap());

        await db.update(
          'user_focusactivities',
          updated.toLocalMap(),
          where: 'id = ?',
          whereArgs: [fokus.id],
        );

        final index = state.indexWhere((item) => item.id == fokus.id);
        if (index != -1) {
          final newList = [...state];
          newList[index] = updated;
          state = newList;
        }
      }
    } catch (error, stack) {
      debugPrint('Fehler deleteFokusTaetigkeit: $error');
      debugPrintStack(stackTrace: stack);

      // Zurückrollen im Fehlerfall
      state = previousState;

      // Feedback im UI
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Löschen fehlgeschlagen. Bitte versuch es nochmal einmal.'),
          ),
        );
      }
    }
  }

  Future<void> insertFokusTaetigkeitToCloud(FokusTaetigkeit fokus) async {
    await _getFokusRef().doc(fokus.id).set(fokus.toFirebaseMap());
  }

  void insertAt(int index, FokusTaetigkeit fokus, BuildContext context) async {
    try {
      // Firebase
      await insertFokusTaetigkeitToCloud(fokus);

      // lokaleDB
      final db = await getDatabase();
      await db.insert('user_focusactivities', fokus.toLocalMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );    
      
      // lokaler State
      final newList = [...state];
      newList.insert(index, fokus);
      state = newList;
    } catch (error, stackTrace) {
      debugPrint('Fehler insertAt: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wiederherstellen fehlgeschlagen. Bitte versuch es nochmal einmal.')),
        );
      }
    }
  }
}

final userFokusActivitiesProvider = StateNotifierProvider<UserFokusActivitiesNotifier, List <FokusTaetigkeit>>(
  (ref) => UserFokusActivitiesNotifier(),
);

final showInactiveProvider = StateProvider<bool>((ref) => false);


