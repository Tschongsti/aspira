import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap({bool forFirebase = false}) {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName.name,
      'weeklyGoal': weeklyGoal.inMinutes,
      'startDate': forFirebase
        ? Timestamp.fromDate(startDate)
        : startDate.toLocal().toIso8601String(),
      'loggedTime': loggedTime.inMinutes,
      'status': status.name,
    };
  }

  Map<String, dynamic> toFirebaseMap() => toMap(forFirebase: true);
  Map<String, dynamic> toLocalMap() => toMap();

  factory FokusTaetigkeit.fromMap(Map<String, dynamic> map) {
    return FokusTaetigkeit(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      iconName: IconName.values.firstWhere(
        (error) => error.name == map['iconName'],
        orElse: () => IconName.favorite, // fallback
      ),
      weeklyGoal: Duration(minutes: map['weeklyGoal']),
      startDate:map['startDate'] is Timestamp
        ? (map['startDate'] as Timestamp).toDate()
        : DateTime.parse(map['startDate']),
      loggedTime: Duration(minutes: map['loggedTime']),
      status: Status.values.firstWhere(
        (error) => error.name == map['status'],
        orElse: () => Status.active, // fallback
      ),
    );
  }

}
