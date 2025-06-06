import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/models/fokus_taetigkeiten.dart';
import 'package:aspira/models/task_timer.dart';
import 'package:aspira/models/trackable_task.dart';
import 'package:aspira/providers/timer_ticker_provider.dart';
import 'package:aspira/providers/task_timer_provider.dart';
import 'package:aspira/providers/user_focusactivities_provider.dart';
import 'package:aspira/providers/daily_execution_provider.dart';
import 'package:aspira/providers/weekly_sum_provider.dart';
import 'package:aspira/utils/appscreenconfig.dart';
import 'package:aspira/utils/appscaffold.dart';
import 'package:aspira/widgets/Homescreen/homescreen_task.dart';

class HomeScreen extends ConsumerStatefulWidget{
  const HomeScreen ({super.key});

  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeScreenState();
  }

}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  
  void setupPushNotifications () async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();
    
    fcm.subscribeToTopic('development_updates');
  }

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contextCopy = context; // für mounted check
      ref.read(userFokusActivitiesProvider.notifier).loadFokusActivities(contextCopy);
    });
    
    setupPushNotifications();
  } 

  List<DateTime> getCurrentWeekDates() {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getCurrentWeekDates();
    final monthYear = DateFormat('MMMM yyyy', 'de_CH').format(selectedDate);
    bool isSameDay(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }
    
    final config = AppScreenConfig(
      title: monthYear,
      showBottomNav: true,
      showAppBar: true,
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: (){},
      ),
      appBarActions: [
        IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
        ),
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            context.push('/profile');
          },
        ),
      ]
    );
  
    final allFokus = ref.watch(userFokusActivitiesProvider);
    final fokusForToday = allFokus.where((fokus) =>
      fokus.status == Status.active &&
      isSameDay(fokus.startDate, selectedDate)
    ).toList();

    return AppScaffold(
      config: config,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
              child: Row(
                children: weekDates.map((date) {
                  final isSelected = DateUtils.isSameDay(date, selectedDate);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedDate = date),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.purple : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('E', 'de_CH').format(date),
                              style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                            ),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Tagesfokus", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _placeholderCard("Noch kein Fokus erfasst"),
            const SizedBox(height: 24),
            const Text("To-Do", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _placeholderCard("Keine To-Do's heute"),
            const SizedBox(height: 24),
            const Text("To-Relax", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _placeholderCard("Noch keine Pause eingeplant"),
            const SizedBox(height: 24),
            const Text("Tracking", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            fokusForToday.isEmpty
              ? _placeholderCard("Keine Fokustätigkeit gestartet")
              : Column(
                  children: fokusForToday.map((task) {
                    final timer = ref.watch(taskTimerProvider)[task.id];
                    final isRunning = timer?.isRunning ?? false;
                    final elapsed = timer?.elapsed ?? Duration.zero;
                    final loggedTime = _computeLoggedTime(ref, task, selectedDate, elapsed);

                    if (isRunning) {
                      ref.watch(tickerProvider); // sekündlicher Widget rebuild (nur aktiv, wenn nötig)
                    }
                    
                    return HomescreenTask(
                      type: TaskType.timer,
                      icon: Icon(Icons.access_time), // du kannst später task.iconName zu einem echten Icon mappen
                      title: task.title,
                      loggedTime: loggedTime,
                      goalTime: task.weeklyGoal,
                      isRunning: isRunning, // Platzhalter – wird später dynamisch sein
                      onTapMainAction: () {
                        final timerNotifier = ref.read(taskTimerProvider.notifier);
                          if (isRunning) {
                            timerNotifier.pauseTimer(task.id, task, context);
                          } else if (timer?.status == TaskTimerStatus.paused) {
                            timerNotifier.resumeTimer(task.id);
                          } else {
                            timerNotifier.startTimer(task.id);
                          }
                        },
                      onEdit: () {
                        // später für manuelle Bearbeitung
                        debugPrint('Edit gedrückt für ${task.title}');
                      },
                    );
                  }).toList(),
                ),
          ],
        ),
      ),
    );
  }

  Duration _computeLoggedTime(
    WidgetRef ref,
    TrackableTask task,
    DateTime selectedDate,
    Duration elapsed,
  ) {
    if (task is FokusTaetigkeit) {
      final asyncWeekly = ref.watch(weeklySumProvider(task));
      final weeklySum = asyncWeekly.value ?? Duration.zero;
      return weeklySum + elapsed;
    } else {
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final asyncDaily = ref.watch(
        dailyExecutionProvider((task: task, date: startOfDay)),
      );
      final dailySum = asyncDaily.value
          ?.map((entry) => entry.duration)
          .fold(Duration.zero, (a, b) => a + b) ?? Duration.zero;

      return dailySum + elapsed;
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