import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aspira/data/database.dart'; // notwendig für Reset Visited Screens
import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/appscreenconfig.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _resetVisitedScreens(BuildContext context) async {
    final db = await getDatabase();
    await db.delete('visited_screens');

    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('visited_screens-Tabelle wurde zurückgesetzt')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = AppScreenConfig(title: 'Mein Profil');

    return AppScaffold(
      config: config,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              context.push('/profile/notifications');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFF8D6CCB),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 72),
              side: BorderSide.none,
            ),
            icon: const Icon(Icons.start),
            label: const Text('Benachrichtigungen'),
          ),
          const SizedBox(height: 32),
          // 🛠️ Dev-Reset-Button
          OutlinedButton.icon(
            onPressed: () => _resetVisitedScreens(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 60),
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Visited Screens resetten'),
          ),
        ],
      ),
    );
  }
}
