import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/providers/repos/execution_entry_repo_provider.dart';
import 'package:aspira/providers/repos/focus_activities_repo_provider.dart';
import 'package:aspira/providers/repos/user_profile_repo_provider.dart';
import 'package:aspira/services/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    userProfileRepo: ref.read(userProfileRepositoryProvider),
    focusActivityRepo: ref.read(focusActivitiesRepositoryProvider),
    executionRepo: ref.read(executionEntriesRepositoryProvider),
  );
});
