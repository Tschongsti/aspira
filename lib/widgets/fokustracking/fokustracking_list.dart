import 'package:flutter/material.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/widgets/fokustracking/fokustracking_item.dart';

class FokustrackingList extends StatelessWidget{
  const FokustrackingList ({
    required this.fokusTaetigkeiten,
    required this.onRemoveFokustaetigkeit,
    super.key,
  });

  final List<FokusTaetigkeit> fokusTaetigkeiten;
  final void Function(FokusTaetigkeit fokusTaetigkeit) onRemoveFokustaetigkeit;

 @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: fokusTaetigkeiten.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(fokusTaetigkeiten[index]),
        background: Container(
          color: Colors.red,
          margin: EdgeInsets.symmetric(
            horizontal: 16,
          ),
        ),
        onDismissed: (direction) {
            onRemoveFokustaetigkeit(fokusTaetigkeiten[index]);
        },
        child: FokustrackingItem(
          fokusTaetigkeiten[index],
        ),
      ),
    );
  }
}