import 'package:flutter/material.dart';
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

class Aspira extends StatefulWidget {
  const Aspira({super.key});

  @override
  State<Aspira> createState() {
    return _Aspira();
  }
}

class _Aspira extends State<Aspira> {
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