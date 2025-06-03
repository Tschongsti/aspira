import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:aspira/providers/visited_screens_provider.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });

    ref.listen<Set<String>>(visitedScreensProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref ref;
  late final StreamSubscription<User?> _authSub;

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

}