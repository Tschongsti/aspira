import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/data/database.dart'; // notwendig für Reset Visited Screens
import 'package:aspira/models/user_profile.dart';
import 'package:aspira/providers/user_profile_provider.dart';
import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/appscreenconfig.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _resetLocalDatabase(BuildContext context) async {
    final db = await getDatabase();

    await db.delete('visited_screens');
    await db.delete('user_focusactivities');
    await db.delete('execution_entries');
    await db.delete('user_profile');
    // später ggf. ergänzen: 'user_habits', 'user_todos', 'user_relax', usw.

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lokale Datenbank wurde zurückgesetzt')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final user = FirebaseAuth.instance.currentUser!;
    final dummyProfile = UserProfile.empty(user.uid, user.email ?? '');

    final config = AppScreenConfig(
      title: 'Mein Profil',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final currentProfile = profileAsync.value ?? dummyProfile;
            final updatedProfile = await context.push<UserProfile>(
              '/profile/edit',
              extra: currentProfile,
            );

            if (updatedProfile != null) {
              await ref.read(userProfileProvider.notifier).saveProfile(updatedProfile);
              }
          },
        ),
      ],
    );
    
    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Fehler beim Laden: $error')),
      ),
      data: (profile) {
        final effectiveProfile = profile ?? dummyProfile;

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
                  backgroundImage: effectiveProfile.photoUrl != null 
                    ? NetworkImage(effectiveProfile.photoUrl!)
                    : null,
                  child: effectiveProfile.photoUrl == null 
                    ? const Icon(Icons.person, size: 32) 
                    : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  effectiveProfile.displayName?.isNotEmpty == true
                      ? effectiveProfile.displayName!
                      : 'Kein Name gesetzt',
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
            onPressed: () => _resetLocalDatabase(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 60),
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Reset Local Database'),
          ),
        ],
      ),
    );
  },
);
}}