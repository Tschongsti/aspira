import 'package:flutter/material.dart';

enum Status { active, inactive, deleted }
enum Type { task, quantity, time }

abstract class TrackableTask {
  final String id;
  final String userId;
  final String title;
  final String description;
  final IconData iconData;
  final DateTime startDate;
  final Status status;
  final Duration loggedTime;
  final bool isArchived;

  final DateTime updatedAt;
  final bool isDirty;

  final Type type;

  TrackableTask({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.iconData,
    required this.startDate,
    required this.status,
    required this.loggedTime,
    required this.isArchived,
    required this.updatedAt,
    required this.isDirty,
    required this.type,
  }) : assert(userId.isNotEmpty); // Debug-Check (keine Task ohne userId erfassbar)

  String get parentCollection; // FokusTätigkeit, Gewohnheit, ToDo, ToRelax

  Map<String, dynamic> toLocalMap();
  factory TrackableTask.fromLocalMap(Map<String, dynamic> map) =>
      throw UnimplementedError('Implement in subclasses');
}