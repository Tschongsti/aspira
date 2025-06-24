import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/repositories/focus_activities_repo.dart';
import 'package:aspira/providers/firebase_provider.dart';

final focusActivitiesRepositoryProvider = Provider<FocusActivitiesRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  return FocusActivitiesRepository(firestore: firestore);
});