import 'package:flutter/material.dart';

import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/appscreenconfig.dart';

class SchlaftrackingScreen extends StatelessWidget{
  const SchlaftrackingScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppScreenConfig(
    title: 'Schlaf verbessern');

    return AppScaffold(
      config: config,
      child: Center(
        child: Text ('SchlaftrackingScreen'),
      ),
    );
  }
}