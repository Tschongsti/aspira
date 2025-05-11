import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aspira/buttons/button_navigation.dart';

class InsTunKommenScreen extends StatelessWidget{
  const InsTunKommenScreen (this.focusTracking, {super.key});

  final void Function () focusTracking;

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
              'Ins Tun kommen',
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
                      icon: Icons.repeat,
                      text: 'Gewohnheiten aneignen'
                    ),
                    const SizedBox(height: 30),
                    ButtonNavigation(
                      onPressed: focusTracking,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      icon: Icons.search,
                      text: 'Fokus-Tätigkeiten festlegen'
                    ),
                    const SizedBox(height: 30),
                    ButtonNavigation(
                      onPressed: (){},
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      icon: Icons.hotel,
                      text: 'Schlaf verbessern'
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