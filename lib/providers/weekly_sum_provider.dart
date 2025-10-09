import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/data/database.dart';
import 'package:aspira/models/execution_entry.dart';

typedef WeeklyInput = ({String taskId, DateTime weekStart});

final weeklySumProvider = FutureProvider.family
    .autoDispose<Duration, WeeklyInput>((ref, input) async {
  final db = await getDatabase();
  final start = DateTime(input.weekStart.year, input.weekStart.month, input.weekStart.day);
  final end = start.add(const Duration(days: 7)); 
  
  final result = await db.query(
    'execution_entries',
    where: 'taskId = ? AND start >= ? AND start < ? AND isArchived = 0 AND status != ?',
    whereArgs: [
      input.taskId,
      start.toIso8601String(),
      end.toIso8601String(),
      'deleted',
    ],
  );

  return result
      .map((item) => ExecutionEntry.fromLocalMap(item).duration)
      .fold<Duration>(Duration.zero, (sum, dur) => sum + dur);
});
