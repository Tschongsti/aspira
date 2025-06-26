import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:aspira/providers/user_profile_provider.dart';
import 'package:aspira/providers/user_focusactivities_provider.dart';
import 'package:aspira/providers/auth_provider.dart';
import 'package:aspira/providers/sync_services_provider.dart';

Future<void> logout(WidgetRef ref, BuildContext context) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await ref.read(syncServiceProvider).syncOnLogoutOrExit(user.uid);
      debugPrint('[Logout] SyncOnLogout erfolgreich abgeschlossen');
    }
  } catch (e) {
    debugPrint('[Logout] Fehler beim SyncOnLogout: $e');
  }

  try {
    await FirebaseAuth.instance.signOut();
    debugPrint('[Logout] FirebaseAuth signOut erfolgreich');

    // 🧠 Warten bis Firebase wirklich null zurückgibt
    int retries = 0;
    while (FirebaseAuth.instance.currentUser != null && retries < 10) {
      debugPrint('[Logout] Warte auf currentUser == null...');
      await Future.delayed(const Duration(milliseconds: 50));
      retries++;
    }

  } catch (e) {
    debugPrint('[Logout] Fehler beim Firebase signOut: $e');
  }

  // Zustand nur bei StateNotifier/AsyncNotifier/ChangeNotifier-basierten Providern invalidieren

  ref.invalidate(userProfileProvider);
  ref.invalidate(userFokusActivitiesProvider);
  ref.invalidate(authStateProvider);
  ref.invalidate(syncServiceProvider);

  debugPrint('[Logout] Alles invalidiert, bereit für neuen Login');

  // Optional: Lokale Daten löschen
  // final db = await getDatabase();
  // await db.delete('user_profile');
  // await db.delete('user_focusactivities');
}