import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sqflite/sqflite.dart';

import 'package:aspira/models/user_profile.dart';
import 'package:aspira/data/database.dart';

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final db = await getDatabase();
    final result = await db.query('user_profile', limit: 1);
    if (result.isNotEmpty) {
      state = UserProfile.fromMap(result.first);
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
    state = updated;
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>(
  (ref) => UserProfileNotifier(),
);
