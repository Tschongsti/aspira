import 'package:flutter/material.dart';

import 'package:aspira/screens/start_screen.dart';
import 'package:aspira/screens/instunkommen_screen.dart';
import 'package:aspira/widgets/fokustracking/fokustracking.dart';


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
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF5F7F8),
                Color(0xFFF5F7F8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: screenWidget,
        ),
      ),
    );
  }
}