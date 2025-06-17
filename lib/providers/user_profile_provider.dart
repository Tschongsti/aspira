import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:sqflite/sqflite.dart';

import 'package:aspira/models/user_profile.dart';
import 'package:aspira/data/database.dart';
import 'package:aspira/utils/db_helpers.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier(this.ref) : super(const AsyncLoading()) {
    loadProfile();
  }

  final Ref ref;

  Future<void> loadProfile() async {
    try {
      final uid = ref.read(firebaseUidProvider);
      if (uid == null) {
        state = const AsyncValue.data(null);
        return;
      }
      
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
    final updated = profile.copyWith(
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
    final existing = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (existing.isEmpty) {
      final profile = UserProfile.empty(id, email);
      await db.insert('user_profile', profile.toMap());
      state = AsyncValue.data(profile);
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
