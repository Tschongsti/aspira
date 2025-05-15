import 'package:aspira/widgets/fokustracking/fokustracking_list.dart';
import 'package:flutter/material.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';

class FokustrackingScreen extends StatefulWidget{
  const FokustrackingScreen ({super.key});

  @override
  State<FokustrackingScreen> createState() {
    return _FokustrackingScreenState();
  }
}

class _FokustrackingScreenState extends State<FokustrackingScreen> {
  final List<FokusTaetigkeit> _registeredFokusTaetigkeit = [
  
    FokusTaetigkeit(
      title: 'berufliches Networking',
      iconName: 'diversity3',
      weeklyGoal: Duration(minutes: 120),
    ),

    FokusTaetigkeit(
      title: 'Zeit in der Natur verbringen',
      iconName: 'landscape2',
      weeklyGoal: Duration(minutes: 240),
    ),
  ];

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

      Widget mainContent = const Center(
      child: Text('Keine Fokus-Tätigkeiten gefunden. Bitte füge eine hinzu!'),
      );

      if (_registeredFokusTaetigkeit.isNotEmpty) {
        mainContent = FokustrackingList(
              fokusTaetigkeiten: _registeredFokusTaetigkeit,
              onRemoveFokustaetigkeit: _removeFokustaetigkeit,
            );
    }

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: (){},
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text ('Fokus Tätigkeiten'),
          actions: [
            IconButton(
              onPressed: (){},
              icon: const Icon(Icons.help),
            ),
            IconButton(
              onPressed: (){},
              icon: const Icon(Icons.add),
            ), 
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: mainContent,
            ),
          ],
        ),
      );
    } 
}
