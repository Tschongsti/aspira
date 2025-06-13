import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:duration/duration.dart';

import 'package:flutter_iconpicker/flutter_iconpicker.dart';

import 'package:aspira/models/trackable_task.dart';

final formatter = DateFormat('dd.MM.yyyy');

const uuid = Uuid();

class FokusTaetigkeit extends TrackableTask {
  final Duration weeklyGoal;
  
  FokusTaetigkeit({
    required super.userId,
    required super.title,
    required super.description,
    required super.iconData,
    required this.weeklyGoal,
    String? id,
    DateTime? startDate,
    Duration? loggedTime,
    bool? isArchived,
    Status? status,
    DateTime? updatedAt,
    bool? isDirty,
    }) : super( 
      id: id ?? uuid.v4(),
      startDate: startDate ?? DateTime.now(),
      status: status ?? Status.active,
      loggedTime: loggedTime ?? Duration.zero,
      isArchived: isArchived ?? false,
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
      'userId': userId,
      'title': title,
      'description': description,
      'iconJson': jsonEncode(
        serializeIcon(
          IconPickerIcon(
            name: iconData.codePoint.toString(),
            data: iconData,
            pack: IconPack.lineAwesomeIcons,
          ),
        ),
      ),
      'startDate': startDate.toLocal().toIso8601String(),
      'status': status.name,
      'loggedTime': loggedTime.inMinutes,
      'isArchived': isArchived ? 1 : 0,
      'updatedAt': updatedAt.toLocal().toIso8601String(),
      'isDirty': isDirty ? 1 : 0,
      'type': type.name,
      'weeklyGoal': weeklyGoal.inMinutes,
    };
  }

  factory FokusTaetigkeit.fromLocalMap(Map<String, dynamic> map) {
    final iconJsonRaw = map['iconJson'];
    final iconMap = iconJsonRaw != null ? jsonDecode(iconJsonRaw) : null;
    final deserializedIcon = iconMap != null ? deserializeIcon(iconMap) : null;

    if (deserializedIcon == null) {
      debugPrint('⚠️ Icon konnte nicht deserialisiert werden: $iconJsonRaw');
    }
    
    return FokusTaetigkeit(   
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'] ?? '',
      iconData: deserializedIcon?.data ?? Icons.hourglass_empty,
      startDate: DateTime.parse(map['startDate']),
      status: Status.values.firstWhere(
        (error) => error.name == map['status'],
        orElse: () => Status.active,
      ),
      loggedTime: Duration(minutes: map['loggedTime'] ?? 0),
      isArchived: (map['isArchived'] ?? 0) == 1,
      updatedAt: DateTime.parse(map['updatedAt']),
      isDirty: map['isDirty'] == 1,
      weeklyGoal: Duration(minutes: map['weeklyGoal'] ?? 0),
    );
  }

  FokusTaetigkeit copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    IconData? iconData,
    DateTime? startDate,
    Status? status,
    Duration? loggedTime,
    bool? isArchived,
    DateTime? updatedAt,
    bool? isDirty,
    Duration? weeklyGoal,
  }) {
    return FokusTaetigkeit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      iconData: iconData ?? this.iconData,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      loggedTime: loggedTime ?? this.loggedTime,
      isArchived: isArchived ?? this.isArchived,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
    );
  }

}
