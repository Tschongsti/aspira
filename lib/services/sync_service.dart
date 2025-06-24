import 'package:aspira/repositories/execution_entry_repo.dart';
import 'package:aspira/repositories/focus_activities_repo.dart';
import 'package:aspira/repositories/user_profile_repo.dart';

class SyncService {
  final UserProfileRepository userProfileRepo;
  final FocusActivitiesRepository focusActivityRepo;
  final ExecutionEntriesRepository executionRepo;

  SyncService({
    required this.userProfileRepo,
    required this.focusActivityRepo,
    required this.executionRepo,
  });

  /// Wird bei Login oder App-Start aufgerufen:
  /// Ziel: alle aktuellen Daten aus Firestore holen und lokal mergen
  Future<void> syncOnLoginOrStart(String userId) async {
    await userProfileRepo.downloadAndMerge(userId);
    await focusActivityRepo.downloadAndMerge(userId);
    await executionRepo.downloadAndMerge(userId);
  }

  /// Wird bei App-Ende oder Logout aufgerufen:
  /// Ziel: alle lokalen Änderungen (isDirty == true) in Firestore hochladen
  Future<void> syncOnLogoutOrExit(String userId) async {
    await userProfileRepo.uploadIfDirty(userId);
    await focusActivityRepo.uploadIfDirty(userId);
    await executionRepo.uploadIfDirty(userId);
  }
}
