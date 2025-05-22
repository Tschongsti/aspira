import 'package:aspira/screens/tabs.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartScreen extends StatelessWidget {
    const StartScreen (this.startApp, {super.key});

    final void Function () startApp;

    @override
    Widget build(context) {
      return Center( 
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo-aspira.png',
            width: 200,
            ),
          SizedBox (height: 16),
          Text(
              'Become You',
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8D6CCB),
              ),
            ),
          SizedBox (height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => TabsScreen(),
                ),
              );
            },          
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Color(0xFF8D6CCB),
              padding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 72,
              ),
              side: BorderSide.none,
            ),
            icon: const Icon(Icons.start),
            label: const Text('Start App'),
          ),
        ],
      ),
    );
  }
}
