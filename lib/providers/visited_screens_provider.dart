import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sqflite/sqflite.dart';

import 'package:aspira/data/database.dart';

final visitedScreensProvider = StateNotifierProvider<VisitedScreensNotifier, Set<String>>((ref) {
  return VisitedScreensNotifier()..loadVisitedScreens();
});

class VisitedScreensNotifier extends StateNotifier<Set<String>> {
  VisitedScreensNotifier() : super({});

  Future<void> loadVisitedScreens() async {
    final db = await getDatabase();
    final data = await db.query('visited_screens');

    final screens = data.map((row) => row['screenId'] as String).toSet();
    state = screens;
  }

  Future<void> markVisited(String screenId) async {
    final db = await getDatabase();
    await db.insert(
      'visited_screens',
      {'screenId': screenId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    state = {...state, screenId};
  }

  bool isVisited(String screenId) {
    return state.contains(screenId);
  }
}
