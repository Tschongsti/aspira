import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:duration/duration.dart';

import 'package:aspira/models/trackable_task.dart';

final formatter = DateFormat('dd.MM.yyyy');

const uuid = Uuid();

const categoryIcons = {
  IconName.landscape: Icons.landscape,
  IconName.diversity_3: Icons.diversity_3,
  IconName.favorite: Icons.favorite,
};

class FokusTaetigkeit extends TrackableTask {
  final Duration weeklyGoal;
  
  FokusTaetigkeit({
    required super.title,
    required super.description,
    required super.iconName,
    required this.weeklyGoal,
    String? id,
    DateTime? startDate,
    Duration? loggedTime,
    Status? status,
    DateTime? updatedAt,
    bool? isDirty,
    }) : super( 
      id: id ?? uuid.v4(),
      startDate: startDate ?? DateTime.now(),
      status: status ?? Status.active,
      loggedTime: loggedTime ?? Duration.zero,
      updatedAt: updatedAt ?? DateTime.now(),
      isDirty: isDirty ?? true,
      type: Type.time,
    );

  @override
  String get parentCollection => 'fokus_activities';

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

  @override
  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName.name,
      'startDate': startDate.toLocal().toIso8601String(),
      'status': status.name,
      'loggedTime': loggedTime.inMinutes,
      'updatedAt': updatedAt.toLocal().toIso8601String(),
      'isDirty': isDirty ? 1 : 0,
      'type': type.name,
      'weeklyGoal': weeklyGoal.inMinutes,
    };
  }

  factory FokusTaetigkeit.fromLocalMap(Map<String, dynamic> map) {
    return FokusTaetigkeit(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      iconName: IconName.values.firstWhere(
        (error) => error.name == map['iconName'],
        orElse: () => IconName.favorite, // Fallback
      ),
      startDate: DateTime.parse(map['startDate']),
      status: Status.values.firstWhere(
        (error) => error.name == map['status'],
        orElse: () => Status.active,
      ),
      loggedTime: Duration(minutes: map['loggedTime'] ?? 0),
      updatedAt: DateTime.parse(map['updatedAt']),
      isDirty: map['isDirty'] == 1,
      weeklyGoal: Duration(minutes: map['weeklyGoal'] ?? 0),
    );
  }

  FokusTaetigkeit copyWith({
    String? id,
    String? title,
    String? description,
    IconName? iconName,
    DateTime? startDate,
    Status? status,
    Duration? loggedTime,
    DateTime? updatedAt,
    bool? isDirty,
    Duration? weeklyGoal,
  }) {
    return FokusTaetigkeit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      loggedTime: loggedTime ?? this.loggedTime,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
    );
  }

}
