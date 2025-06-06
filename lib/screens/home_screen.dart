import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:go_router/go_router.dart';

import 'package:aspira/utils/appscreenconfig.dart';
import 'package:aspira/utils/appscaffold.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen ({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }

}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  
  void setupPushNotifications () async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();
    
    fcm.subscribeToTopic('development_updates');
  }

  @override
  void initState() {
    super.initState();
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
            _placeholderCard("Keine Fokustätigkeit gestartet"),
          ],
        ),
      ),
    );
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