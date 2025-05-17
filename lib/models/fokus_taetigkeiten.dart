import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:duration/duration.dart';

final formatter = DateFormat.yMd();

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
    }) : id = uuid.v4();

  final String id;
  final String title;
  final String description;
  final IconName iconName;
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
