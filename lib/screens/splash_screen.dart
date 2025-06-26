import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/providers/auth_provider.dart';
import 'package:aspira/providers/user_profile_provider.dart';
import 'package:aspira/providers/sync_services_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[SplashScreen] build gestartet');

    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        debugPrint('[SplashScreen] authStateProvider lieferte: ${user?.uid ?? 'null'}');

        Future.microtask(() async {
          final currentUser = FirebaseAuth.instance.currentUser;

          // 🛡️ Inkonstistenter Zustand abfangen: user != null, aber Firebase denkt noch nicht ausgeloggt
          if (user != null && currentUser == null) {
            debugPrint('[SplashScreen] UID vorhanden, aber currentUser == null. Warte ab...');
            await Future.delayed(const Duration(milliseconds: 100));
            return;
          }
          
          if (user != null) {
            debugPrint('[SplashScreen] Eingeloggt, lade Profil');
            
            try {
              await ref.read(syncServiceProvider).syncOnLoginOrStart(user.uid);
              debugPrint('[Login] SyncOnLogin erfolgreich abgeschlossen');
            } catch (e) {
              debugPrint('[SplashScreen] Fehler bei syncOnLoginOrStart: $e');
            }
            
            await ref.read(userProfileProvider.notifier).loadProfile(user);        
            
            if (context.mounted) context.go('/home');
          } else {
            debugPrint('[SplashScreen] Nicht eingeloggt, gehe zu /start');
            if (context.mounted) context.go('/start');
          }
        });

        // 🌀 Währenddessen bleibt Splash sichtbar
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      loading: () {
        debugPrint('[SplashScreen] Lade Auth-State...');
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, _) {
        debugPrint('[SplashScreen] Fehler: $error');
        return const Scaffold(
          body: Center(child: Text('Fehler beim Laden')),
        );
      },
    );
  }
}