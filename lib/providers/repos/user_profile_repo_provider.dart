import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/repositories/user_profile_repo.dart';
import 'package:aspira/providers/firebase_provider.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  return UserProfileRepository(firestore: firestore);
});