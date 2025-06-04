import 'package:firebase_auth/firebase_auth.dart';

User getCurrentUserOrThrow() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('Kein eingeloggter Benutzer gefunden.');
  }
  return user;
}