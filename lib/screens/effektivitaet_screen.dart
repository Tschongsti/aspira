import 'package:flutter/material.dart';

import 'package:aspira/utils/appscreenconfig.dart';
import 'package:aspira/utils/appscaffold.dart';

class EffektivitaetScreen extends StatelessWidget{
  const EffektivitaetScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppScreenConfig(
      title: 'Effektivität');
    
    return AppScaffold(
      config: config,
      child: const Center(
        child: Text ('Die richtigen Dinge tun Screen'),
      ),
    );
  }
}