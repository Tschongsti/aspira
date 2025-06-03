import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/utils/appscreenconfig.dart';
import 'package:aspira/utils/appscaffold.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen ({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }

}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  Widget build(BuildContext context) {
    final config = AppScreenConfig(
      title: 'Home',
      showBottomNav: true,
      showAppBar: true,
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: (){},
      ),
      appBarActions: [
        IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
        ),
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            context.push('/profile');
          },
        ),
      ]
    );
  
    return AppScaffold(
      config: config,
      child: const Center (
        child: Text('HomeScreen'),
      ),
    );
  }
}