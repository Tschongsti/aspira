import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:aspira/data/database.dart';
import 'package:aspira/models/execution_entry.dart';

class ExecutionEntriesRepository {
  final FirebaseFirestore firestore;

  ExecutionEntriesRepository({required this.firestore});

  Future<void> downloadAndMerge(String userId) async {
    try {
      final db = await getDatabase();

      final taskSnapshot = await firestore
        .collection('user_focusactivities')
        .doc(userId)
        .collection('entries')
        .get();

      for (final taskDoc in taskSnapshot.docs) {
        final taskId = taskDoc.id;

        final execSnapshot = await firestore
          .collection('user_focusactivities')
          .doc(userId)
          .collection('entries')
          .doc(taskId)
          .collection('executions')
          .get();

        for (final execDoc in execSnapshot.docs) {
          final remote = ExecutionEntry.fromLocalMap(execDoc.data());

          final localResult = await db.query(
            'execution_entries',
            where: 'id = ?',
            whereArgs: [remote.id],
            limit: 1,
          );

          if (localResult.isEmpty) {
            await db.insert('execution_entries', {
              ...remote.toLocalMap(),
              'isDirty': 0,
            });
            debugPrint('⬇️ Execution eingefügt: ${remote.id}');
          } else {
            final local = ExecutionEntry.fromLocalMap(localResult.first);
            if (remote.updatedAt.isAfter(local.updatedAt)) {
              await db.update(
                'execution_entries',
                {
                  ...remote.toLocalMap(),
                  'isDirty': 0,
                },
                where: 'id = ?',
                whereArgs: [remote.id],
              );
              debugPrint('🔄 Execution aktualisiert: ${remote.id}');
            } else {
              debugPrint('⏭️ Lokale Execution aktueller: ${remote.id}');
            }
          }
        }
      }
    } catch (error) {
      debugPrint('❌ Fehler beim Download von Executions: $error');
    }
  }

  Future<void> uploadIfDirty(String userId) async {
    try {
      final db = await getDatabase();
      final dirtyRows = await db.query(
        'execution_entries',
        where: 'isDirty = 1',
      );

      for (final row in dirtyRows) {
        final exec = ExecutionEntry.fromLocalMap(row);

        await firestore
          .collection('user_focusactivities')
          .doc(userId)
          .collection('entries')
          .doc(exec.taskId)
          .collection('executions')
          .doc(exec.id)
          .set({
            ...exec.toLocalMap(),
            'isDirty': 0,
          });

        await db.update(
          'execution_entries',
          {'isDirty': 0},
          where: 'id = ?',
          whereArgs: [exec.id],
        );

        debugPrint('☁️ Execution hochgeladen: ${exec.id}');
      }
    } catch (error) {
      debugPrint('❌ Fehler beim Upload von Executions: $error');
    }
  }
}
