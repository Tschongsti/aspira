import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:duration/duration.dart';

final formatter = DateFormat.yMd();

const uuid = Uuid();

enum Status { active, inactive, deleted }

class FokusTaetigkeit {
  FokusTaetigkeit({
    required this.title,
    required this.iconName,
    required this.weeklyGoal,
    }) : id = uuid.v4();

  final String id;
  final String title;
  final String iconName;
  final Duration weeklyGoal;
  var startDate = DateTime.now();
  var loggedTime = Duration.zero;
  Status status = Status.active;

  String get formattedDate {
    return formatter.format(startDate);
  }

  String get formattedLoggedTime {
    return prettyDuration(loggedTime);
  }

}
