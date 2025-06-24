import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:aspira/data/database.dart';
import 'package:aspira/models/fokus_taetigkeiten.dart';

class FocusActivitiesRepository {
  final FirebaseFirestore firestore;

  FocusActivitiesRepository({required this.firestore});

  Future<void> downloadAndMerge(String userId) async {
    try {
      final db = await getDatabase();
      final snapshot = await firestore
        .collection('user_focusactivities')
        .doc(userId)
        .collection('entries')
        .get();

      for (final doc in snapshot.docs) {
        final remote = FokusTaetigkeit.fromLocalMap(doc.data());

        final localResult = await db.query(
          'user_focusactivities',
          where: 'id = ?',
          whereArgs: [remote.id],
          limit: 1,
        );

        if (localResult.isEmpty) {
          await db.insert('user_focusactivities', {
            ...remote.toLocalMap(),
            'isDirty': 0,
          });
          debugPrint('⬇️ Eingefügt: ${remote.title}');
        } else {
          final local = FokusTaetigkeit.fromLocalMap(localResult.first);
          if (remote.updatedAt.isAfter(local.updatedAt)) {
            await db.update(
              'user_focusactivities',
              {
                ...remote.toLocalMap(),
                'isDirty': 0,
              },
              where: 'id = ?',
              whereArgs: [remote.id],
            );
            debugPrint('🔄 Aktualisiert: ${remote.title}');
          } else {
            debugPrint('⏭️ Lokaler Eintrag aktueller: ${remote.title}');
          }
        }
      }
    } catch (error) {
      debugPrint('❌ Fehler beim Download FokusAktivitäten: $error');
    }
  }

  Future<void> uploadIfDirty(String userId) async {
    try {
      final db = await getDatabase();
      final dirtyRows = await db.query(
        'user_focusactivities',
        where: 'isDirty = 1',
      );

      for (final row in dirtyRows) {
        final task = FokusTaetigkeit.fromLocalMap(row);
        await firestore
            .collection('user_focusactivities')
            .doc(userId)
            .collection('entries')
            .doc(task.id)
            .set({
              ...task.toLocalMap(),
              'isDirty': 0,
        });

        await db.update(
          'user_focusactivities',
          {'isDirty': 0},
          where: 'id = ?',
          whereArgs: [task.id],
        );

        debugPrint('☁️ Hochgeladen: ${task.title}');
      }
    } catch (error) {
      debugPrint('❌ Fehler beim Upload FokusAktivitäten: $error');
    }
  }
}
