import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/repositories/execution_entry_repo.dart';
import 'package:aspira/providers/firebase_provider.dart';

final executionEntriesRepositoryProvider = Provider<ExecutionEntriesRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  return ExecutionEntriesRepository(firestore: firestore);
});