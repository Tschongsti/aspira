import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:sqflite/sqflite.dart';

import 'package:aspira/models/user_profile.dart';
import 'package:aspira/data/database.dart';
import 'package:aspira/utils/db_helpers.dart';
import 'package:aspira/providers/auth_provider.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier(this.ref) : super(const AsyncLoading()) {
    debugPrint('[UserProfileNotifier] Konstruktor wurde aufgerufen');
  }

  final Ref ref;

  Future<void> loadProfile() async {
    debugPrint('[UserProfileNotifier] loadProfile triggered');
    
    final authAsync = ref.read(authStateProvider);

    debugPrint('[UserProfileNotifier] authStateProvider: $authAsync');

    final uid = authAsync.value?.uid;

    debugPrint('[UserProfileNotifier] UID: $uid');

    if (uid == null) {
        state = const AsyncValue.data(null);
        return;
    }
    
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

    final uid = ref.read(firebaseUidProvider);
    final user = ref.read(firebaseUserProvider);
    
    if (uid == null || user?.email == null) {
      state = const AsyncValue.data(null);
      return;
    }

    final existing = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [uid],
    );

    if (existing.isEmpty) {
      final profile = UserProfile.empty(uid, user!.email!);
      await db.insert('user_profile', profile.toMap());
      state = AsyncValue.data(profile);
      debugPrint('[UserProfileNotifier] createIfNotExists aufgerufen für UID: $uid');
    }
  }

}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>(
  (ref) => UserProfileNotifier(ref),
);

final firebaseUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

final firebaseUidProvider = Provider<String?>((ref) {
  return ref.watch(firebaseUserProvider)?.uid;
});
