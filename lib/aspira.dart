import 'package:flutter/material.dart';

import 'package:aspira/screens/start_screen.dart';
import 'package:aspira/screens/instunkommen_screen.dart';
import 'package:aspira/widgets/fokustracking/fokustracking.dart';

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
      activeScreen = 'InsTunKommen-screen';
    });
  }

  void focusTracking() {
    setState(() {
      activeScreen = 'FokusTracking-screen';
    });
  }

  @override
  Widget build(context) {
    Widget screenWidget = StartScreen(startApp);

    if (activeScreen == 'InsTunKommen-screen') {
      screenWidget = InsTunKommenScreen(focusTracking
      );
    }

    if (activeScreen == 'FokusTracking-screen') {
      screenWidget = FokustrackingScreen(
      );
    }

    return MaterialApp(
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
      ),
      home: Scaffold(
        body: Container(
        child: screenWidget,
        ),
      ),
    );
  }
}