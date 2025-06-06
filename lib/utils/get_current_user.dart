import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

User getCurrentUserOrThrow() {
  final user = FirebaseAuth.instance.currentUser;
  debugPrint('getCurrentUserOrThrow Check: ${user?.uid ?? "NULL"}');
  if (user == null) {
    throw Exception('Kein eingeloggter Benutzer gefunden.');
  }
  return user;
}