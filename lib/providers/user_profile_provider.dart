import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:sqflite/sqflite.dart';

import 'package:aspira/models/user_profile.dart';
import 'package:aspira/data/database.dart';
import 'package:aspira/utils/db_helpers.dart';
import 'package:aspira/providers/auth_provider.dart';
import 'package:aspira/providers/repos/user_profile_repo_provider.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier(this.ref) : super(const AsyncLoading()) {
    debugPrint('[UserProfileNotifier] Konstruktor wurde aufgerufen');
  }

  final Ref ref;

  Future<void> loadProfile(User user) async {
    debugPrint('[UserProfileNotifier] loadProfile triggered');

    final uid = user.uid;

    debugPrint('[UserProfileNotifier] UID (via param): $uid');

    try {
      final result = await queryById(
        table: 'user_profile',
        id: uid,
      );

      if (result.isNotEmpty) {
        state = AsyncValue.data(UserProfile.fromMap(result.first));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final db = await getDatabase();

    final uid = ref.read(firebaseUidProvider);
    if (uid == null) {
      state = const AsyncValue.data(null);
      return;
    }

    final updated = profile.copyWith(
      id: uid,
      updatedAt: DateTime.now(),
      isDirty: true,
    );

    await db.insert(
      'user_profile',
      updated.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    state = AsyncValue.data(updated);
  }

  Future<void> createIfNotExists(String id, String email) async {
    final db = await getDatabase();

    // 🔍 Check: Gibt es das Profil lokal?
    final existing = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (existing.isEmpty) {
      debugPrint('[UserProfileNotifier] Kein lokales Profil vorhanden für UID: $id');

      try {
        // 🔁 Versuche, das Profil aus Firestore zu laden und zu mergen
        await ref.read(userProfileRepositoryProvider).downloadAndMerge(id);
        
      } catch (e) {
        // 🔧 Wenn kein Remote-Profil vorhanden ist → leeres Profil erstellen
        debugPrint('[UserProfileNotifier] Remote-Profil NICHT gefunden → erstelle leeres Profil für UID: $id');

        final profile = UserProfile.empty(id, email);
        await db.insert('user_profile', profile.toMap());
        state = AsyncValue.data(profile);
        return;
      }

      debugPrint('[UserProfileNotifier] Remote-Profil erfolgreich geladen und gemergt für UID: $id');

    } else {
      debugPrint('[UserProfileNotifier] Profil existiert bereits lokal für UID: $id');
    }
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>(
  (ref) => UserProfileNotifier(ref),
);

final firebaseUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});
