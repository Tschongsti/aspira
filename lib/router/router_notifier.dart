import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint('👤 Auth state changed: ${user?.uid}');
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