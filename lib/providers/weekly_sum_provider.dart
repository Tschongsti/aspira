import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/data/database.dart';
import 'package:aspira/models/execution_entry.dart';
import 'package:aspira/models/trackable_task.dart';


final weeklySumProvider = FutureProvider.family
    .autoDispose<Duration, TrackableTask>((ref, task) async {
  final db = await getDatabase();
  final now = DateTime.now();
  final startOfWeek = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1)); // Montag 00:00

  final result = await db.query(
    'execution_entries',
    where: 'taskId = ? AND start >= ? AND isArchived = 0',
    whereArgs: [
      task.id,
      startOfWeek.toIso8601String(),
    ],
  );

  return result
      .map((item) => ExecutionEntry.fromLocalMap(item).duration)
      .fold<Duration>(Duration.zero, (sum, dur) => sum + dur);
});
