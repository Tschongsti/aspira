import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:aspira/router/app_router.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0XFF8D6CCB),
);

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color(0xFFBCA7E6),
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((fn) {
  runApp(
    const ProviderScope(
      child: AspiraApp(),
    ),
  );
  });
}

class AspiraApp extends StatelessWidget {
  const AspiraApp({super.key});

  @override
  Widget build(context) {
    return MaterialApp.router(
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        textTheme: GoogleFonts.interTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorScheme.primaryContainer,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: kColorScheme.primary,
          selectedItemColor: kColorScheme.onPrimary,
          unselectedItemColor: kColorScheme.onSecondary,
          ),
        ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
      ),
      routerConfig: appRouter,
    );
  }
}
