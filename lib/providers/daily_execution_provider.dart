import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aspira/models/execution_entry.dart';
import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/utils/get_current_user.dart';

final dailyExecutionProvider = FutureProvider.family
    .autoDispose<List<ExecutionEntry>, ({TrackableTask task, DateTime date})>(
  (ref, params) async {
    final user = getCurrentUserOrThrow();
    final task = params.task;
    final date = params.date;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(task.parentCollection)
        .doc(task.id)
        .collection('executions')
        .where('start', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('start', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs
        .map((doc) => ExecutionEntry.fromMap(doc.data()))
        .toList();
  },
);
