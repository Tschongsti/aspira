import 'package:flutter/material.dart';

import 'package:aspira/providers/notifications_filter_provider.dart';
import 'package:aspira/widgets/switchlisttile_notifikationen.dart';

class BenachrichtigungenScreen extends StatelessWidget{
  const BenachrichtigungenScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text ('Benachrichtigungen'),
      ),
      body: Column(
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