import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:aspira/data/database.dart';
import 'package:aspira/models/user_profile.dart';

class UserProfileRepository {
  final FirebaseFirestore firestore;

  UserProfileRepository({required this.firestore});

  /// Download aus Firestore → lokal mergen
  Future<void> downloadAndMerge(String userId) async {
    final db = await getDatabase();
    final doc = await firestore.collection('user_profiles').doc(userId).get();

    if (!doc.exists) {
      debugPrint('📭 Kein UserProfile in Firestore gefunden für $userId');
      throw Exception('Kein Remote-Profil gefunden');
    }

    final remote = UserProfile.fromMap(doc.data()!);

    final localResult = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (localResult.isEmpty) {
      await db.insert('user_profile', {
        ...remote.toMap(),
        'isDirty': 0,
      });
      debugPrint('⬇️ UserProfile aus Firestore neu eingefügt: ${remote.email}');
    } else {
      final local = UserProfile.fromMap(localResult.first);
      if (remote.updatedAt.isAfter(local.updatedAt)) {
        await db.update(
          'user_profile',
          {
            ...remote.toMap(),
            'isDirty': 0,
          },
          where: 'id = ?',
          whereArgs: [userId],
        );
        debugPrint('🔄 UserProfile aus Firestore aktualisiert: ${remote.email}');
      } else {
        debugPrint('⏭️ Lokales UserProfile ist aktueller: kein Update nötig');
      }
    }
  }

  /// Upload aus SQLite → Firestore (wenn isDirty == true)
  Future<void> uploadIfDirty(String userId) async {
    try {
      final db = await getDatabase();
      final result = await db.query(
        'user_profile',
        where: 'id = ? AND isDirty = 1',
        whereArgs: [userId],
        limit: 1,
      );

      if (result.isEmpty) {
        debugPrint('📤 Kein UserProfile mit isDirty=true gefunden: kein Upload nötig');
        return;
      }

      final local = UserProfile.fromMap(result.first);
      final dataForFirestore = local.toMap()..remove('isDirty');

      await firestore.collection('user_profiles').doc(userId).set(dataForFirestore);
      debugPrint('⬆️ UserProfile nach Firestore hochgeladen: ${local.email}');

      await db.update(
        'user_profile',
        {'isDirty': 0},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (error) {
      debugPrint('❌ Fehler beim Upload von UserProfile: $error');
    }
  }
}
