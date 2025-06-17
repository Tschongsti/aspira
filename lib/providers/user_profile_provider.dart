import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:sqflite/sqflite.dart';

import 'package:aspira/models/user_profile.dart';
import 'package:aspira/data/database.dart';
import 'package:aspira/utils/db_helpers.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier(this.ref) : super(const AsyncLoading()) {
    // Beim Start inital laden
    loadProfile();

    // Wenn sich UID ändert (z. B. Login/Logout), erneut laden
    ref.listen<String?>(firebaseUidProvider, (prev, next) {
      if (prev != next) {
        loadProfile();
      }
    });
  }

  final Ref ref;

  Future<void> loadProfile() async {
    final uid = ref.read(firebaseUidProvider);
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
