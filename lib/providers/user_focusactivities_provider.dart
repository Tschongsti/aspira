import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sqflite/sqlite_api.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/data/database.dart';


class UserFokusActivitiesNotifier extends StateNotifier<List<FokusTaetigkeit>> {
  UserFokusActivitiesNotifier() : super(const []);

  Future<void> loadFocusActivities() async {
    final db = await getDatabase();
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception ('Kein eingeloggter Benutzer gefunden.');
    }

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

  void remove(FokusTaetigkeit fokus) async {
    
    final db = await getDatabase();
    await db.delete(
      'user_focusactivities',
      where: 'id = ?',
      whereArgs: [fokus.id],
    );
    
    state = [...state]..remove(fokus);
  }

  void insertAt(int index, FokusTaetigkeit fokus) async {
    
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
    
    final newList = [...state];
    newList.insert(index, fokus);
    state = newList;
  }
}

final userFokusActivitiesProvider = StateNotifierProvider<UserFokusActivitiesNotifier, List <FokusTaetigkeit>>(
  (ref) => UserFokusActivitiesNotifier(),
);