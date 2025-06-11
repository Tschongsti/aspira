import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sqflite/sqflite.dart';

import 'package:uuid/uuid.dart';

import 'package:aspira/data/database.dart';
import 'package:aspira/models/task_timer.dart';
import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/models/execution_entry.dart';

class TaskTimerNotifier extends StateNotifier<Map<String, TaskTimer>> {
  TaskTimerNotifier() : super({});

  final Map<String, DateTime> _currentExecutions = {};

  void startTimer(String taskId) {
    final existing = state[taskId];
    if (existing != null && existing.isRunning) return;

    final newTimer = existing?.start() ?? TaskTimer(
      taskId: taskId,
      accumulated: Duration.zero,
      status: TaskTimerStatus.running,
      startedAt: DateTime.now(),
      ).start();
    _currentExecutions[taskId] = DateTime.now();
    state = {
      ...state,
      taskId: newTimer,
    };
  }

  void resumeTimer(String taskId) {
    final existing = state[taskId];
    if (existing == null || existing.isRunning) return;

    final resumed = existing.start();
    _currentExecutions[taskId] = DateTime.now();
    state = {
      ...state,
      taskId: resumed,
    };
  }

  Future<void> pauseTimer(String taskId, TrackableTask task, BuildContext context) async {
    final existing = state[taskId];
    if (existing == null || !existing.isRunning) return;

    final paused = existing.pause();
    state = {
      ...state,
      taskId: paused,
    };

    final execution = ExecutionEntry(
      id: const Uuid().v4(),
      taskId: taskId,
      start: _currentExecutions[taskId]!,
      end: DateTime.now(),
      isDirty: true,
      isArchived: false,
      updatedAt: DateTime.now(),
    );

    try {
      final db = await getDatabase();
      await db.insert(
        'execution_entries',
        execution.toLocalMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _currentExecutions.remove(taskId); // Aufräumen, um keinen unnötigen Speicher zu belegen

    } catch (error, stackTrace) {
      debugPrint('🛑 Fehler beim lokalen Speichern der ExecutionEntry: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim lokalen Speichern der Tracking-Daten')),
        );
      }
    }
  }

  void resetTimer(String taskId) {
    if (!state.containsKey(taskId)) return;
    final reset = state[taskId]!.reset();
    state = {
      ...state,
      taskId: reset,
    };
    _currentExecutions.remove(taskId);
  }

  Duration getElapsed(String taskId) => state[taskId]?.elapsed ?? Duration.zero;

  bool isRunning(String taskId) => state[taskId]?.isRunning ?? false;
}

final taskTimerProvider = StateNotifierProvider<TaskTimerNotifier, Map<String, TaskTimer>>(
  (ref) => TaskTimerNotifier(),
);

final anyTimerRunningProvider = Provider<bool>((ref) {
  final timers = ref.watch(taskTimerProvider);
  return timers.values.any((t) => t.isRunning);
});