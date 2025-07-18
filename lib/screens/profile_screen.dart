import 'dart:io';

import 'package:aspira/repositories/execution_entry_repo.dart';
import 'package:aspira/repositories/focus_activities_repo.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/data/database.dart'; // notwendig für Reset Visited Screens
import 'package:aspira/models/user_profile.dart';
import 'package:aspira/providers/user_profile_provider.dart';
import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/appscreenconfig.dart';

import 'package:aspira/services/sync_service.dart';
import 'package:aspira/repositories/user_profile_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _resetLocalDatabase(BuildContext context) async {
    final db = await getDatabase();

    await db.delete('user_focusactivities');
    await db.delete('execution_entries');
    await db.delete('user_profile');
    // später ggf. ergänzen: 'user_habits', 'user_todos', 'user_relax', usw.

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lokale Datenbank wurde zurückgesetzt')),
    );
  }

  Future<void> _exportDatabase(BuildContext context) async {
    try {
      final databasesPath = await sql.getDatabasesPath();
      final dbPath = path.join(databasesPath, 'aspira.db');

      final appDir = await getTemporaryDirectory(); // aus path_provider
      final exportPath = path.join(appDir.path, 'aspira_export.db');

      final exportFile = File(exportPath);
      await File(dbPath).copy(exportPath);

      final params = ShareParams(
        text: 'Hier ist die aktuelle Aspira-Datenbank',
        files: [XFile(exportFile.path)],
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        debugPrint('✅ Erfolgreich geteilt!');
      } else {
        debugPrint('ℹ️ Teilen abgebrochen oder nicht erfolgreich.');
      }

    } catch (e) {
      debugPrint('❌ Fehler beim DB-Export: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Exportieren der Datenbank')),
      );
    }
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
              debugPrint('🔁 Zurückgekommen mit updatedProfile: ${updatedProfile.displayName}');
              await ref.read(userProfileProvider.notifier).saveProfile(updatedProfile);
            
            } else {
              debugPrint('📭 Zurückgekommen ohne Profil-Update');
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
            // 🛠️ Dev-Buttons
            const Text('App-Entwicklung (Entfernung nach Beta-Test)'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  FirebaseCrashlytics.instance.crash(); // absichtlicher Crash

                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 243, 2, 35),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                ),
                icon: const Icon(Icons.bug_report),
                label: const Text('App Crash auslösen'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _exportDatabase(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                ),
                icon: const Icon(Icons.file_upload),
                label: const Text('Export Local DB'),
              ),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final userId = profile.id; // aus geladenem Profil
                  final syncService = SyncService(
                    userProfileRepo: UserProfileRepository(firestore: FirebaseFirestore.instance),
                    focusActivityRepo: FocusActivitiesRepository(firestore: FirebaseFirestore.instance),
                    executionRepo: ExecutionEntriesRepository(firestore: FirebaseFirestore.instance),
                  );
                  await syncService.syncOnLoginOrStart(userId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('⬇️ Sync bei Login/Start ausgeführt')),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                ),
                icon: const Icon(Icons.cloud_download),
                label: const Text('Sync: Login / Start'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final userId = profile.id;
                  final syncService = SyncService(
                    userProfileRepo: UserProfileRepository(firestore: FirebaseFirestore.instance),
                    focusActivityRepo: FocusActivitiesRepository(firestore: FirebaseFirestore.instance),
                    executionRepo: ExecutionEntriesRepository(firestore: FirebaseFirestore.instance),
                  );
                  await syncService.syncOnLogoutOrExit(userId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('⬆️ Sync bei Logout/Exit ausgeführt')),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                ),
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Sync: Logout / Exit'),
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