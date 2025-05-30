import 'package:flutter/material.dart';

import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/appscreenconfig.dart';

class GewohnheitstrackingScreen extends StatelessWidget{
  const GewohnheitstrackingScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppScreenConfig(
      title: 'Gewohnheiten');

    return AppScaffold(
      config: config,
      child: Center(
        child: Text ('GewohnheitstrackingScreen'),
      ),
    );
  }
}