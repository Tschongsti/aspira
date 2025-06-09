import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/data/database.dart'; // notwendig für Reset Visited Screens
import 'package:aspira/models/user_profile.dart';
import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/appscreenconfig.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser!;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('user_profile')
        .doc('main');

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        setState(() {
          _userProfile = UserProfile.fromMap(user.uid, snapshot.data()!);
        });
      }
    } catch (error) {
      debugPrint('Fehler loadUserProfile: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }   
  
  Future<void> _resetLocalDatabase(BuildContext context) async {
    final db = await getDatabase();

    await db.delete('visited_screens');
    await db.delete('user_focusactivities');
    // später ggf. ergänzen: 'user_habits', 'user_todos', 'user_relax', usw.

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lokale Datenbank wurde zurückgesetzt')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = AppScreenConfig(
      title: 'Mein Profil',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser!;
            final dummy = UserProfile.empty(user.uid, user.email ?? '');

            final updatedProfile = await context.push<UserProfile>(
              '/profile/edit',
              extra: _userProfile ?? dummy,
            );

            if (updatedProfile is UserProfile) {
              setState(() {
                _userProfile = updatedProfile;
              });
            }
          },
        ),
      ],
    );
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  backgroundImage: _userProfile?.photoUrl != null 
                    ? NetworkImage(_userProfile!.photoUrl!)
                    : null,
                  child: _userProfile?.photoUrl == null 
                    ? const Icon(Icons.person, size: 32) 
                    : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _userProfile?.displayName?.isNotEmpty == true
                      ? _userProfile!.displayName!
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
  }
}
