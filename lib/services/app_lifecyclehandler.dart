import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:aspira/providers/sync_services_provider.dart';

class AppLifecycleHandler extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends ConsumerState<AppLifecycleHandler> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('[Lifecycle] App resumed');
        ref.read(syncServiceProvider).syncOnLoginOrStart(user.uid);
        break;

      case AppLifecycleState.inactive:
        debugPrint('[Lifecycle] App inactive');
        ref.read(syncServiceProvider).syncOnLogoutOrExit(user.uid);
        break;

      case AppLifecycleState.paused:
        debugPrint('[Lifecycle] App paused');
        ref.read(syncServiceProvider).syncOnLogoutOrExit(user.uid);
        break;

      case AppLifecycleState.detached:
        debugPrint('[Lifecycle] App detached');
        // In detached ist i.d.R. kein Zugriff mehr auf Provider – meist ignorieren.
        break;

      case AppLifecycleState.hidden:
        debugPrint('[Lifecycle] App hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
