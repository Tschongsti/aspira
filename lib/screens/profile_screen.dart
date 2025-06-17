import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    
    final config = AppScreenConfig(
      title: 'Mein Profil',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final currentProfile = profileAsync.value;
            if (currentProfile == null) return;

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
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text('Profil konnte nicht geladen werden')),
          );
        }

    return AppScaffold(
      config: config,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox (height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: profile.photoUrl != null 
                    ? NetworkImage(profile.photoUrl!)
                    : null,
                  child: profile.photoUrl == null 
                    ? const Icon(Icons.person, size: 32) 
                    : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      profile.displayName?.isNotEmpty == true
                          ? profile.displayName!
                          : 'Kein Benutzername gesetzt',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),          
            SizedBox (height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/profile/notifications');
                },
                child: const Text(
                  'Benachrichtigungen',
                ),
              ),
            ),
            const Spacer(),
            // 🛠️ Dev-Reset-Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _resetLocalDatabase(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Reset Local Database'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  },
);
}}