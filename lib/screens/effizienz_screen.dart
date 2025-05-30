import 'package:flutter/material.dart';

import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/appscreenconfig.dart';

class EffizienzScreen extends StatelessWidget{
  const EffizienzScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppScreenConfig(
      title: 'Effizienz');

    return AppScaffold(
      config: config,
      child: Center(
        child: Text ('Die Dinge richtig tun Screen'),
      ),
    );
  }
}