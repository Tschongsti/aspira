import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/models/task_timer.dart';
import 'package:aspira/providers/task_timer_provider.dart';
import 'package:aspira/providers/timer_ticker_provider.dart';
import 'package:aspira/providers/weekly_sum_provider.dart';
import 'package:aspira/providers/daily_execution_provider.dart';
import 'package:aspira/utils/date_utils.dart';
import 'package:aspira/widgets/Homescreen/homescreen_task.dart';

class TrackingSection extends ConsumerWidget {
  final List<FokusTaetigkeit> tasks;
  final DateTime selectedDate;

  const TrackingSection({
    super.key,
    required this.tasks,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    if (tasks.isEmpty) {
      return _placeholderCard("Noch keine Fokustätigkeit definiert");
    }

    return Column(
      children: tasks.map((task) {
        final timer = ref.watch(taskTimerProvider)[task.id];
        final isRunning = timer?.isRunning ?? false;
        final elapsed = timer?.elapsed ?? Duration.zero;
        final loggedTime = _computeLoggedTime(ref, task, selectedDate, elapsed);
        final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

        final VoidCallback? onTap = isToday
            ? () {
                final timerNotifier = ref.read(taskTimerProvider.notifier);
                if (isRunning) {
                  timerNotifier.pauseTimer(task.id, task, context, ref);
                } else if (timer?.status == TaskTimerStatus.paused) {
                  timerNotifier.resumeTimer(task.id);
                } else {
                  timerNotifier.startTimer(task.id);
                }
              }
            : null;

        if (isRunning) ref.watch(tickerProvider);    
        
        return HomescreenTask(
          type: TaskType.timer,
          icon: Icon(task.iconData),
          title: task.title,
          loggedTime: loggedTime,
          goalTime: task.weeklyGoal,
          isRunning: isRunning,
          onTapMainAction: onTap,
          onEdit: !selectedDate.isAfter(DateTime.now())
            ? () {
                final timers = ref.read(taskTimerProvider);
                final anyRunning = timers.values.any((t) => t.isRunning);
                if (anyRunning) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Beende zuerst alle Timer, bevor du Änderungen vornehmen kannst.'),
                    ),
                  );
                } else {
                  ref.invalidate(taskTimerProvider); // 🧹 elapsed auf 0 setzen
                  context.push(
                    '/edit',
                    extra: {
                      'task': task,
                      'selectedDate': selectedDate,
                    },
                  );
                }
              }
            : null,
        );
      }).toList(),
    );
  }
  
  Duration _computeLoggedTime(
    WidgetRef ref,
    TrackableTask task,
    DateTime selectedDate,
    Duration elapsed,
  ) {
    if (task is FokusTaetigkeit) {
      final (weekStart, weekEnd) = weekWindow(selectedDate);
      final asyncWeekly = ref.watch(weeklySumProvider((taskId: task.id, weekStart: weekStart)));
      final weeklySum = asyncWeekly.value ?? Duration.zero;
      final addWeeklyElapsed = isSameWeek(selectedDate, DateTime.now());
      return weeklySum + (addWeeklyElapsed ? elapsed : Duration.zero);
    } else {
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final asyncDaily = ref.watch(
        dailyExecutionProvider((task: task, date: startOfDay)),
      );
      final dailySum = asyncDaily.value
          ?.map((entry) => entry.duration)
          .fold(Duration.zero, (a, b) => a + b) ?? Duration.zero;

      final addDailyElapsed = DateUtils.isSameDay(selectedDate, DateTime.now());
      return dailySum + (addDailyElapsed ? elapsed : Duration.zero);
    }
  }

  Widget _placeholderCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black54)),
    );
  }
}
