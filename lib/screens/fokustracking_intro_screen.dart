import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/providers/firstvisit_provider.dart';
import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/utils/appscreenconfig.dart';

class FokustrackingIntroScreen extends ConsumerWidget {
  const FokustrackingIntroScreen ({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = AppScreenConfig(
      title: 'Fokustätigkeit Intro',
      showBottomNav: false,
      );
    
    return AppScaffold(
      config: config,
      child: OutlinedButton.icon(
        onPressed: () {
          ref.read(firstVisitProvider.notifier).markVisited('fokus');
          context.go('/ins-tun/fokus');
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
        label: const Text('Los gehts!'),
      ),
    );
  }
}