import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:aspira/providers/user_profile_provider.dart';
import 'package:aspira/providers/user_focusactivities_provider.dart';
import 'package:aspira/providers/auth_provider.dart';

Future<void> logout(WidgetRef ref, BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  ref.invalidate(userProfileProvider);
  ref.invalidate(userFokusActivitiesProvider);
  ref.invalidate(authStateProvider);

  debugPrint('[Logout] Alles invalidiert, bereit für neuen Login');

  // Optional: Lokale Daten löschen
  // final db = await getDatabase();
  // await db.delete('user_profile');
  // await db.delete('user_focusactivities');
}