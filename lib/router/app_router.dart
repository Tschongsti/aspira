import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/providers/visited_screens_provider.dart';
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
import 'package:aspira/screens/fokustracking_new_item.dart';
import 'package:aspira/screens/gewohnheitstracking_screen.dart';
import 'package:aspira/screens/schlaftracking_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/start',
    refreshListenable: routerNotifier,
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
        redirect: (context, state) => 
          ref.read(visitedScreensProvider).contains('fokus')
            ? null
            : '/ins-tun/fokus/intro',
        builder: (context, state) => const FokustrackingScreen(),
      ),
      GoRoute(
        path: '/ins-tun/fokus/intro',
        builder: (context, state) => const FokustrackingIntroScreen(),
      ),
      GoRoute(
        path: '/ins-tun/fokus/new',
        builder: (context, state) => const NewFokustaetigkeitScreen(),
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
});