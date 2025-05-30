import 'package:flutter/material.dart';

import 'package:aspira/providers/notifications_filter_provider.dart';
import 'package:aspira/widgets/switchlisttile_notifikationen.dart';
import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/appscreenconfig.dart';

class BenachrichtigungenScreen extends StatelessWidget{
  const BenachrichtigungenScreen ({super.key});

  @override
  Widget build(BuildContext context) {
  final config = AppScreenConfig(
    title: 'Benachrichtigungen');

    return AppScaffold(
      config: config,
      child: Column(
        children: [
          SwitchlisttileNotifikationen(
            filter: Filter.daystart,
            title: 'Optimal in den Tag starten',
            subtitle: 'Erinnerungen für Dankbarkeit am Morgen',
          ),
        ],
      ),
    );
  }
}