import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:aspira/widgets/button_navigation.dart';

class InsTunKommenScreen extends StatelessWidget{
  const InsTunKommenScreen ({super.key});

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
                      onPressed: (){
                        context.push('/ins-tun/gewohnheit');
                      },
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      icon: Icons.repeat,
                      text: 'Gewohnheiten aneignen'
                    ),
                    const SizedBox(height: 30),
                    ButtonNavigation(
                      onPressed: () {
                        context.push('/ins-tun/fokus');
                      },
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      icon: Icons.search,
                      text: 'Fokus-Tätigkeiten festlegen'
                    ),
                    const SizedBox(height: 30),
                    ButtonNavigation(
                      onPressed: (){
                        context.push('/ins-tun/schlaf');
                      },
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