import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/data/database.dart';
import 'package:aspira/models/execution_entry.dart';
import 'package:aspira/models/trackable_task.dart';

final dailyExecutionProvider = FutureProvider.family
    .autoDispose<List<ExecutionEntry>, ({TrackableTask task, DateTime date})>(
  (ref, params) async {
    final db = await getDatabase();
    final startOfDay = DateTime(params.date.year, params.date.month, params.date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    final result = await db.query(
      'execution_entries',
      where: 'taskId = ? AND start >= ? AND start <= ? AND isArchived = 0 AND status = ?',
      whereArgs: [
        params.task.id,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
        ExecutionEntryStatus.active.name,
      ],
    );

    return result.map((item) => ExecutionEntry.fromLocalMap(item)).toList();
  },
);
