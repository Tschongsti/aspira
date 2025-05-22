import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:aspira/screens/start_screen.dart';
import 'package:aspira/screens/tabs.dart';

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

class AspiraApp extends StatefulWidget {
  const AspiraApp({super.key});

  @override
  State<AspiraApp> createState() {
    return _AspiraAppState();
  }
}

class _AspiraAppState extends State<AspiraApp> {
  var activeScreen = 'start-screen';

  void startApp() {
    setState(() {
      activeScreen = 'tabs-screen';
    });
  }

  @override
  Widget build(context) {
    Widget screenWidget = StartScreen(startApp);

    if (activeScreen == 'tabs-screen') {
      screenWidget = const TabsScreen();
    }

    return MaterialApp(
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        textTheme: GoogleFonts.interTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorScheme.primaryContainer,
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
      ),
      home: screenWidget,
    );
  }
}
