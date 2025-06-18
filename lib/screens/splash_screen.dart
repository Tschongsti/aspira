import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aspira/providers/auth_provider.dart';
import 'package:aspira/providers/user_profile_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[SplashScreen] build gestartet');

    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        Future.microtask(() async {
          debugPrint('[SplashScreen] authStateProvider lieferte: ${user?.uid ?? 'null'}');

          if (user != null) {
            debugPrint('[SplashScreen] Eingeloggt, lade Profil');
            await ref.read(userProfileProvider.notifier).loadProfile();
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