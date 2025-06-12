import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:duration/duration.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/providers/total_logged_time_provicder.dart';

class FokustrackingItem extends ConsumerWidget {
  const FokustrackingItem (this.fokusTaetigkeiten, {super.key});

final FokusTaetigkeit fokusTaetigkeiten;

@override
  Widget build(BuildContext context, WidgetRef ref) {

    final durationAsync = ref.watch(totalLoggedTimeProvider(fokusTaetigkeiten.id));

    final loggedTimeDisplay = durationAsync.when(
      data: (duration) => prettyDuration(
        duration,
        abbreviated: true,
        tersity: DurationTersity.minute,
        spacer: '',
        delimiter: '',
      ),
      loading: () => '⏳ lädt...',
      error: (_, __) => 'keine Daten verfügbar',
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
          ),
        child: Row (
          children: [
            Icon (
              fokusTaetigkeiten.iconData,
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
                  loggedTimeDisplay,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}