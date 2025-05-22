import 'package:go_router/go_router.dart';

import 'package:aspira/screens/start_screen.dart';
import 'package:aspira/screens/tabs.dart';
import 'package:aspira/screens/home_screen.dart';
import 'package:aspira/screens/effektivitaet_screen.dart';
import 'package:aspira/screens/effizienz_screen.dart';
import 'package:aspira/screens/profile_screen.dart';
import 'package:aspira/screens/instunkommen_screen.dart';
import 'package:aspira/screens/fokustracking_screen.dart';
import 'package:aspira/screens/gewohnheitstracking_screen.dart';
import 'package:aspira/screens/schlaftracking_screen.dart';


final appRouter = GoRouter(
  initialLocation: '/start',
  routes: [
    GoRoute(
      path: '/start',
      builder: (context, state) => const StartScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => TabsScreen(child: child),
      routes: [
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
          routes: [
            GoRoute(
              path: 'fokus',
              builder: (context, state) => const FokustrackingScreen(),
            ),
            GoRoute(
              path: 'gewohnheiten',
              builder: (context, state) => const GewohnheitstrackingScreen(),
            ),
            GoRoute(
              path: 'schlaf',
              builder: (context, state) => const SchlaftrackingScreen(),
            ),
            ],
          ),
          GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
