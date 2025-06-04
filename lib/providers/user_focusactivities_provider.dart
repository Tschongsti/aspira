import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sqflite/sqlite_api.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/data/database.dart';
import 'package:aspira/utils/get_current_user.dart';


class UserFokusActivitiesNotifier extends StateNotifier<List<FokusTaetigkeit>> {
  UserFokusActivitiesNotifier() : super(const []);

  Future<void> loadFokusActivities() async {
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
    }

    state = fokusActivities;
  }

  void addFokusTaetigkeit(FokusTaetigkeit fokus) async {   
    
    // lokale Speicherung
    final db = await getDatabase();
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

    // Speicherung in Firebase
    final user = getCurrentUserOrThrow();

    final fokusDoc = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('fokus_activities')
      .doc(fokus.id);

    await fokusDoc.set({
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

  Future<void> deleteFokusTaetigkeitFromCloud(String id) async {
    final user = getCurrentUserOrThrow();
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('fokus_activities')
        .doc(id)
        .delete();
  }

  void deleteFokustaetigkeit(FokusTaetigkeit fokus) async { 
    // lokaler State
    state = [...state]..remove(fokus);

    // Firebase
    await deleteFokusTaetigkeitFromCloud(fokus.id);

    // lokaleDB
    final db = await getDatabase();
    await db.delete(
      'user_focusactivities',
      where: 'id = ?',
      whereArgs: [fokus.id],
    );    
  }

  Future<void> insertFokusTaetigkeitToCloud(FokusTaetigkeit fokus) async {
    final user = getCurrentUserOrThrow();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('fokus_activities')
        .doc(fokus.id)
        .set({
      'id': fokus.id,
      'title': fokus.title,
      'description': fokus.description,
      'iconName': fokus.iconName.name,
      'weeklyGoal': fokus.weeklyGoal.inMinutes,
      'startDate': fokus.startDate.toIso8601String(),
      'loggedTime': fokus.loggedTime.inMinutes,
      'status': fokus.status.name,
    });
  }

  void insertAt(int index, FokusTaetigkeit fokus) async {
    // Firebase
    await insertFokusTaetigkeitToCloud(fokus);

    // lokaleDB
    final db = await getDatabase();
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
    
    // lokaler State
    final newList = [...state];
    newList.insert(index, fokus);
    state = newList;
  }
}

final userFokusActivitiesProvider = StateNotifierProvider<UserFokusActivitiesNotifier, List <FokusTaetigkeit>>(
  (ref) => UserFokusActivitiesNotifier(),
);