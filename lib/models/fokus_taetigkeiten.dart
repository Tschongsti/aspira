import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:duration/duration.dart';

final formatter = DateFormat('dd.MM.yyyy');

const uuid = Uuid();

enum Status { active, inactive, deleted }

enum IconName { landscape, diversity_3, favorite}

const categoryIcons = {
  IconName.landscape: Icons.landscape,
  IconName.diversity_3: Icons.diversity_3,
  IconName.favorite: Icons.favorite,
};

class FokusTaetigkeit {
  FokusTaetigkeit({
    required this.title,
    required this.description,
    required this.iconName,
    required this.weeklyGoal,
    String? id,
    DateTime? startDate,
    Duration? loggedTime,
    Status? status,
    }) : 
    id = id ?? uuid.v4(),
    startDate = startDate ?? DateTime.now(),
    loggedTime = loggedTime ?? Duration.zero,
    status = status ?? Status.active;

  final String id;
  final String title;
  final String description;
  final IconName iconName;
  final Duration weeklyGoal;
  final DateTime startDate;
  final Duration loggedTime;
  final Status status;

  String get formattedDate {
    return formatter.format(startDate);
  }

  String get formattedLoggedTime {
    return prettyDuration(
      loggedTime,
      abbreviated: true,               // z. B. 1d 2h 3m
      tersity: DurationTersity.minute, // bis zur Minute (keine Sekunden)
      spacer: '',                      // kein Leerzeichen zwischen Einheit & Zahl
      delimiter: '',
      // abbreviations: {
      //  DurationTersity.day: 'd',
      //  DurationTersity.hour: 'h',
      //  DurationTersity.minute: 'm',
      //  }                   
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName.name,
      'weeklyGoal': weeklyGoal.inMinutes,
      'startDate': startDate.toIso8601String(),
      'loggedTime': loggedTime.inMinutes,
      'status': status.name,
    };
  }

}
