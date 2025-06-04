import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sqflite/sqlite_api.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/data/database.dart';
import 'package:aspira/utils/get_current_user.dart';


class UserFokusActivitiesNotifier extends StateNotifier<List<FokusTaetigkeit>> {
  UserFokusActivitiesNotifier() : super(const []);

  Future<void> loadFokusActivities(BuildContext context) async {
    try {
      final user = getCurrentUserOrThrow();

      // Firestore lesen
      final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('fokus_activities')
        .get();

      final fokusActivities = snapshot.docs.map((doc) {
        final data = doc.data();
        return FokusTaetigkeit(
          id: data['id'] as String,
          title: data['title'] as String,
          description: data['description'] as String,
          iconName: IconName.values.byName(data['iconName'] as String),
          weeklyGoal: Duration(minutes: data['weeklyGoal'] as int),
          startDate: DateTime.parse(data['startDate'] as String),
          loggedTime: Duration(minutes: data['loggedTime'] as int),
          status: Status.values.byName(data['status'] as String),
        );
      }).toList();
      
      // 2. Lokale DB aktualisieren
      final db = await getDatabase();
      await db.delete('user_focusactivities'); // clear cache

      for (final fokus in fokusActivities) {
        await db.insert('user_focusactivities', fokus.toMap());
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
      final user = getCurrentUserOrThrow();

      final fokusDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('fokus_activities')
        .doc(fokus.id);

      await fokusDoc.set(fokus.toMap());
      
      // lokale Speicherung
      final db = await getDatabase();
      await db.insert('user_focusactivities', fokus.toMap());

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

  Future<void> deleteFokusTaetigkeitFromCloud(String id) async {
    final user = getCurrentUserOrThrow();
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('fokus_activities')
        .doc(id)
        .delete();
  }

  void deleteFokustaetigkeit(FokusTaetigkeit fokus, BuildContext context) async { 
    // lokaler State
    final previousState = [...state];
    state = [...state]..remove(fokus);

    try{
      // Firebase
      await deleteFokusTaetigkeitFromCloud(fokus.id);

      // lokaleDB
      final db = await getDatabase();
      await db.delete(
        'user_focusactivities',
        where: 'id = ?',
        whereArgs: [fokus.id],
      );
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
    final user = getCurrentUserOrThrow();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('fokus_activities')
        .doc(fokus.id)
        .set(fokus.toMap());
  }

  void insertAt(int index, FokusTaetigkeit fokus, BuildContext context) async {
    try {
      // Firebase
      await insertFokusTaetigkeitToCloud(fokus);

      // lokaleDB
      final db = await getDatabase();
      await db.insert('user_focusactivities', fokus.toMap(),
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