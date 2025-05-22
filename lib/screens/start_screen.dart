import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class StartScreen extends StatelessWidget {
    const StartScreen ({super.key});

    @override
    Widget build(context) {
      return Scaffold(
        body: Center( 
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
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
                ),
            SizedBox (height: 16),
            OutlinedButton.icon(
              onPressed: () {
                context.go('/home');
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
            ),
      );
  }
}
