import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/screens/edit_executions_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/models/user_profile.dart';
import 'package:aspira/models/trackable_task.dart';
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
import 'package:aspira/screens/fokustracking_details_screen.dart';
import 'package:aspira/screens/gewohnheitstracking_screen.dart';
import 'package:aspira/screens/schlaftracking_screen.dart';
import 'package:aspira/screens/splash_screen.dart';
import 'package:aspira/screens/profile_edit_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      
      if (state.uri.toString() == '/splash') {
        final isLoggedIn = FirebaseAuth.instance.currentUser != null;
        return isLoggedIn ? '/home' : '/start';
      }      

      if(!isLoggedIn) return '/start';
      if (isLoggedIn && state.uri.toString() == '/start') return '/home';

      return null;
    },
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
          final userProfile = state.extra as UserProfile;
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