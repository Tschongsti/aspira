import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/appscreenconfig.dart';

class ProfileScreen extends StatelessWidget{
  const ProfileScreen ({super.key});

  @override
  Widget build(BuildContext context) {
  final config = AppScreenConfig(
    title: 'Mein Profil');

    return AppScaffold(
      config: config,
      child: OutlinedButton.icon(
        onPressed: () {
          context.push('/profile/notifications');
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
        label: const Text('Benachrichtigungen'),
      ),
    );
  }
}