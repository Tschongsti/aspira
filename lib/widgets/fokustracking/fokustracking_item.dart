import 'package:flutter/material.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';

class FokustrackingItem extends StatelessWidget {
  const FokustrackingItem (this.fokusTaetigkeiten, {super.key});

final FokusTaetigkeit fokusTaetigkeiten;

@override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
          ),
        child: Row (
          children: [
            Icon (
              categoryIcons[fokusTaetigkeiten.iconName],
              size: 40,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fokusTaetigkeiten.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox (height: 6),
                Text (
                  fokusTaetigkeiten.formattedDate,
                ),
                const SizedBox (height: 4),
                Text (
                  fokusTaetigkeiten.formattedLoggedTime,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}