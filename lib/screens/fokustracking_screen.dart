import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/appscreenconfig.dart';
import 'package:aspira/widgets/fokustracking/fokustracking_list.dart';
import 'package:aspira/widgets/fokustracking/new_fokustaetigkeit.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';

class FokustrackingScreen extends StatefulWidget{
  const FokustrackingScreen ({super.key});

  @override
  State<FokustrackingScreen> createState() {
    return _FokustrackingScreenState();
  }
}

class _FokustrackingScreenState extends State<FokustrackingScreen> with TickerProviderStateMixin {
  final List<FokusTaetigkeit> _registeredFokusTaetigkeit = [
  
    FokusTaetigkeit(
      title: 'berufliches Networking',
      description: 'An Anlässen teilnehmen, LinkedIN Posts kommentieren',
      iconName: IconName.diversity_3,
      weeklyGoal: Duration(minutes: 120),
    ),

    FokusTaetigkeit(
      title: 'Zeit in der Natur',
      description: 'Spazieren im Park oder Wald',
      iconName: IconName.landscape,
      weeklyGoal: Duration(minutes: 240),
    ),
  ];

  Future<void> _openAddFokustaetigkeit () async {
    final controller = BottomSheet.createAnimationController(this)
      ..duration = const Duration (milliseconds: 1000);
    
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context, 
      transitionAnimationController: controller,
      builder: (ctx) => NewFokustaetigkeit(onAddFokustaetigkeit: _addFokustaetigkeit),
    );
  }

  void _addFokustaetigkeit(FokusTaetigkeit fokusTaetigkeit) {
  setState(() {
    _registeredFokusTaetigkeit.add(fokusTaetigkeit);
  });  
}

  void _removeFokustaetigkeit(FokusTaetigkeit fokusTaetigkeit) {
    final fokusTaetigkeitIndex = _registeredFokusTaetigkeit.indexOf(fokusTaetigkeit);
    setState(() {
      _registeredFokusTaetigkeit.remove(fokusTaetigkeit);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Fokus-Tätigkeit gelöscht.'),
        action: SnackBarAction(
          label: 'Wiederherstellen',
          onPressed: () {
            setState(() {
              _registeredFokusTaetigkeit.insert(fokusTaetigkeitIndex, fokusTaetigkeit);
            });
          },
        ),
      ),
    );
  }

  @override
    Widget build(BuildContext context) {
      final config = AppScreenConfig(
        title: 'Fokus Tätigkeiten',
        appBarActions: [
          IconButton(
              onPressed: () {
                context.push('/ins-tun/fokus/intro');
              },
              icon: const Icon(Icons.help),
            ),
            IconButton(
              onPressed: _openAddFokustaetigkeit,
              icon: const Icon(Icons.add),
            ), 
        ]);

      Widget mainContent = const Center(
      child: Text('Keine Fokus-Tätigkeiten gefunden. Bitte füge eine hinzu!'),
      );

      if (_registeredFokusTaetigkeit.isNotEmpty) {
        mainContent = FokustrackingList(
              fokusTaetigkeiten: _registeredFokusTaetigkeit,
              onRemoveFokustaetigkeit: _removeFokustaetigkeit,
            );
    }

      return AppScaffold (
        config: config,
        child: Column(
          children: [
            Expanded(
              child: mainContent,
            ),
          ],
        ),
      );
    } 
}
