import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/main.dart';
import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/models/user_profile.dart';
import 'package:aspira/providers/user_profile_provider.dart';
import 'package:aspira/router/router_notifier.dart';
import 'package:aspira/screens/start_screen.dart';
import 'package:aspira/screens/home_screen.dart';
import 'package:aspira/screens/effektivitaet_screen.dart';
import 'package:aspira/screens/effizienz_screen.dart';
import 'package:aspira/screens/profile_screen.dart';
import 'package:aspira/screens/benachrichtigungen_screen.dart';
import 'package:aspira/screens/instunkommen_screen.dart';
import 'package:aspira/screens/fokustracking_intro_screen.dart';
import 'package:aspira/screens/fokustracking_screen.dart';
import 'package:aspira/screens/fokustracking_details_screen.dart';
import 'package:aspira/screens/gewohnheitstracking_screen.dart';
import 'package:aspira/screens/schlaftracking_screen.dart';
import 'package:aspira/screens/splash_screen.dart';
import 'package:aspira/screens/profile_edit_screen.dart';
import 'package:aspira/screens/edit_executions_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    refreshListenable: routerNotifier,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/edit',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final task = extras['task'] as TrackableTask;
          final selectedDate = extras['selectedDate'] as DateTime;

          return EditExecutionsScreen(
            task: task,
            selectedDate: selectedDate,
          );
        },
      ),
      GoRoute(
        path: '/effektivitaet',
        builder: (context, state) => const EffektivitaetScreen(),
      ),
      GoRoute(
        path: '/effizienz',
        builder: (context, state) => const EffizienzScreen(),
      ),
      GoRoute(
        path: '/ins-tun',
        builder: (context, state) => const InsTunKommenScreen(),
      ),
      GoRoute(
        path: '/ins-tun/fokus',
        redirect: (context, state) { 
          final visited = ref.read(visitedScreensProvider);
          return visited.contains('fokus')
            ? null
            : '/ins-tun/fokus/intro';
        },
        builder: (context, state) => const FokustrackingScreen(),
      ),
      GoRoute(
        path: '/ins-tun/fokus/intro',
        builder: (context, state) => const FokustrackingIntroScreen(),
      ),
      GoRoute(
        path: '/ins-tun/fokus/new',
        builder: (context, state) => const FokustrackingDetailsScreen(),
      ),
      GoRoute(
        path: '/ins-tun/fokus/edit',
        builder: (context, state) {
          final fokus = state.extra as FokusTaetigkeit;
          return FokustrackingDetailsScreen(initialData: fokus);
        },
      ),
      GoRoute(
        path: '/ins-tun/gewohnheit',
        builder: (context, state) => const GewohnheitstrackingScreen(),
      ),
      GoRoute(
        path: '/ins-tun/schlaf',
        builder: (context, state) => const SchlaftrackingScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) {
          debugPrint("🛤️ /profile/edit Builder aufgerufen");
          debugPrint("📦 Extra: ${state.extra}");
          debugPrint("📍 Aktueller Stack: ${state.uri}");
          
          final userProfile = state.extra as UserProfile?;
          if (userProfile == null) {
            debugPrint("❌ Fehler: state.extra ist null beim Routing");
            return const Scaffold(
              body: Center(child: Text("Fehler beim Laden des Profils")),
            );
          }
          return ProfileEditScreen(userProfile: userProfile);
        },
      ),
      GoRoute(
        path: '/profile/notifications',
        builder: (context, state) => const BenachrichtigungenScreen(),
      )
    ],
  );
});