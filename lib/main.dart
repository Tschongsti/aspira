import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:aspira/utils/styling_theme.dart';
import 'package:aspira/router/app_router.dart';


var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color(0xFFBCA7E6),
);

final container = ProviderContainer();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('de_CH', null);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((fn) {
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: ProviderScope(
        child: AspiraApp(navigatorKey: navigatorKey),
      ),
    ),
  );
  });
}

class AspiraApp extends ConsumerWidget {
  const AspiraApp({
    required this.navigatorKey,
    super.key
    });

  final GlobalKey<NavigatorState> navigatorKey; 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router =ref.watch(appRouterProvider);
    return MaterialApp.router(
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: kColorScheme.surface,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: kColorScheme.primary,
          selectedItemColor: kColorScheme.onPrimary,
          unselectedItemColor: kColorScheme.onPrimary.withAlpha(120),
          type: BottomNavigationBarType.fixed
        ),
        ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
      ),
      routerConfig: router,
    );
  }
}
