import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/data/database.dart'; // notwendig für Reset Visited Screens
import 'package:aspira/models/user_profile.dart';
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
    final config = AppScreenConfig(
      title: 'Mein Profil',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            context.push('/profile/edit');
          },
        ),
      ],
    );
    
    final user = FirebaseAuth.instance.currentUser!;
    final profile = UserProfile(id: user.uid, email: user.email!);

    return AppScaffold(
      config: config,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  top: 24,
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: profile.photoUrl != null 
                    ? NetworkImage(profile.photoUrl!)
                    : null,
                  child: profile.photoUrl == null 
                    ? const Icon(Icons.person, size: 32) 
                    : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  profile.displayName ?? 'Kein Name gesetzt',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),          
          SizedBox (height: 48,),
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
