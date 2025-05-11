import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aspira/buttons/button_navigation.dart';

class FokusTrackingScreen extends StatelessWidget{
  const FokusTrackingScreen ({super.key});

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
              'Fokus Tätigkeiten festlegen',
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8D6CCB),
              ),
            ),
          ),
          Expanded(
            child: Center (
              child: Padding (
                padding: const EdgeInsets.symmetric(
                  horizontal: 24
                  ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    ButtonNavigation(
                      onPressed: (){},
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      icon: Icons.add_circle,
                      text: 'Neue Fokus-Tätigkeit erfassen'
                    ),
                    const SizedBox(height: 30),
                    ButtonNavigation(
                      onPressed: (){},
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      icon: Icons.edit,
                      text: 'Bestehende Fokus-Tätigkeiten verwalten'
                    ),
                    const SizedBox(height: 30),
                    ButtonNavigation(
                      onPressed: (){},
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.black,
                      icon: Icons.monitor,
                      text: 'Auswertung'
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
}