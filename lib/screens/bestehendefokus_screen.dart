import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aspira/buttons/button_navigation.dart';
import 'package:aspira/data/bestehendefokus_data.dart';
import 'package:aspira/utils/icon_mapping.dart';

class BestehendeFokusScreen extends StatelessWidget{
  const BestehendeFokusScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height:40),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16),
            child: Text(
              'Bestehende Fokus-Tätigkeiten',
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8D6CCB),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: ListView.builder(
                itemCount: bestehendeFokus.length,
                itemBuilder: (context, index) {
                  final eintrag = bestehendeFokus[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ButtonNavigation(
                        onPressed: () {}, // später zu "Fokus-Tätigkeit bearbeiten" navigieren
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        icon: getIcon(eintrag.iconName), // oder dynamisch je nach Titel
                        text: '${eintrag.title}\nStart: ${_formatDate(eintrag.startDate)}\nTotal: ${_formatDuration(eintrag.totalTime)}',
                      ),
                    );
                  },
                ),
            ),
          ),
        ],
      );
    }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

String _formatDuration(Duration duration) {
  final d = duration.inDays;
  final h = duration.inHours % 24;
  final m = duration.inMinutes % 60;

  final dayStr = d > 0 ? '${d}d' : '';
  final hourStr = h > 0 ? '${h}h' : '';
  final minStr = m > 0 ? '${m}m' : '';

  return [dayStr, hourStr, minStr].where((e) => e.isNotEmpty).join(' ');
}
