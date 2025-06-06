import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aspira/models/task_timer.dart';

class TaskTimerNotifier extends StateNotifier<Map<String, TaskTimer>> {
  TaskTimerNotifier() : super({});

  void start(String taskId) {
    final existing = state[taskId];
    final newTimer = existing?.start() ??
        TaskTimer(
          taskId: taskId,
          accumulated: Duration.zero,
          status: TaskTimerStatus.running,
          startedAt: DateTime.now(),
        );
    state = {...state, taskId: newTimer};
  }

  void pause(String taskId) {
    final existing = state[taskId];
    if (existing == null) return;
    state = {...state, taskId: existing.pause()};
  }

  void resume(String taskId) {
    final existing = state[taskId];
    if (existing == null) return;
    state = {...state, taskId: existing.resume()};
  }

  void reset(String taskId) {
    final existing = state[taskId];
    if (existing == null) return;
    state = {...state, taskId: existing.reset()};
  }

  Duration getElapsed(String taskId) => state[taskId]?.elapsed ?? Duration.zero;

  bool isRunning(String taskId) => state[taskId]?.isRunning ?? false;
}

final taskTimerProvider =
    StateNotifierProvider<TaskTimerNotifier, Map<String, TaskTimer>>(
  (ref) => TaskTimerNotifier(),
);
