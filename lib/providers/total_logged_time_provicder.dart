import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aspira/data/database.dart';
import 'package:aspira/models/execution_entry.dart';

final totalLoggedTimeProvider = FutureProvider.family<Duration, String>((ref, taskId) async {
  final db = await getDatabase();

  final data = await db.query(
    'execution_entries',
    where: 'taskId = ? AND isArchived = 0',
    whereArgs: [taskId],
  );

  final totalDuration = data
      .map((item) => ExecutionEntry.fromMap(item).duration)
      .fold<Duration>(Duration.zero, (sum, dur) => sum + dur);

  return totalDuration;
});
