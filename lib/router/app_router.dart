import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/providers/firstvisit_provider.dart';
import 'package:aspira/screens/start_screen.dart';
import 'package:aspira/screens/tabs.dart';
import 'package:aspira/screens/home_screen.dart';
import 'package:aspira/screens/effektivitaet_screen.dart';
import 'package:aspira/screens/effizienz_screen.dart';
import 'package:aspira/screens/profile_screen.dart';
import 'package:aspira/screens/benachrichtigungen_screen.dart';
import 'package:aspira/screens/instunkommen_screen.dart';
import 'package:aspira/screens/fokustracking_intro_screen.dart';
import 'package:aspira/screens/fokustracking_screen.dart';
import 'package:aspira/screens/gewohnheitstracking_screen.dart';
import 'package:aspira/screens/schlaftracking_screen.dart';

bool hasSeenIntro(BuildContext context, String key) {
  final container = ProviderScope.containerOf(context, listen: false);
  return container.read(firstVisitProvider.notifier).isVisited(key);
}

final appRouter = GoRouter(
  initialLocation: '/start',
  routes: [
    GoRoute(
      path: '/start',
      builder: (context, state) => const StartScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
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
      builder: (context, state) =>
        hasSeenIntro(context, 'fokus')
          ? const FokustrackingScreen()
          : const FokustrackingIntroScreen(),
    ),
    GoRoute(
      path: '/ins-tun/fokus/intro',
      builder: (context, state) => const FokustrackingIntroScreen(),
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
      path: '/profile/notifications',
      builder: (context, state) => const BenachrichtigungenScreen(),
    )
  ],
);
