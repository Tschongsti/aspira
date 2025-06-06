import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aspira/models/execution_entry.dart';
import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/utils/get_current_user.dart';

final weeklySumProvider = FutureProvider.family
    .autoDispose<Duration, TrackableTask>((ref, task) async {
  final user = getCurrentUserOrThrow();

  final now = DateTime.now();
  final startOfWeek = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1)); // Montag 00:00

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection(task.parentCollection)
      .doc(task.id)
      .collection('executions')
      .where('start', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
      .get();

  final total = snapshot.docs
      .map((doc) => ExecutionEntry.fromMap(doc.data()))
      .fold<Duration>(
        Duration.zero,
        (sum, entry) => sum + entry.duration,
      );

  return total;
});
