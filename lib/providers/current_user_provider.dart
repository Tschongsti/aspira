import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

final currentUserIdProvider = Provider<String>((ref) {
  final auth = FirebaseAuth.instance;
  return auth.currentUser?.uid ?? 'unknown';
});
