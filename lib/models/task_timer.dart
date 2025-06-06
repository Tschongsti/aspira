enum TaskTimerStatus { idle, running, paused }

class TaskTimer {
  final String taskId;
  final Duration accumulated;
  final DateTime? startedAt;
  final TaskTimerStatus status;

  TaskTimer({
    required this.taskId,
    required this.accumulated,
    required this.status,
    this.startedAt,
  });

  bool get isRunning => status == TaskTimerStatus.running;

  Duration get elapsed {
    if (startedAt == null || status != TaskTimerStatus.running) return accumulated;
    return accumulated + DateTime.now().difference(startedAt!);
  }

  TaskTimer start() {
    if (isRunning) return this;
    return TaskTimer(
      taskId: taskId,
      accumulated: accumulated,
      startedAt: DateTime.now(),
      status: TaskTimerStatus.running,
    );
  }

  TaskTimer pause() {
    if (!isRunning || startedAt == null) return this;
    return TaskTimer(
      taskId: taskId,
      accumulated: elapsed,
      startedAt: null,
      status: TaskTimerStatus.paused,
    );
  }

  TaskTimer resume() {
    if (status != TaskTimerStatus.paused) return this;
    return TaskTimer(
      taskId: taskId,
      accumulated: accumulated,
      startedAt: DateTime.now(),
      status: TaskTimerStatus.running,
    );
  }

  TaskTimer reset() {
    return TaskTimer(
      taskId: taskId,
      accumulated: Duration.zero,
      startedAt: null,
      status: TaskTimerStatus.idle,
    );
  }
}
