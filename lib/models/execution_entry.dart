import 'package:cloud_firestore/cloud_firestore.dart';

class ExecutionEntry {
  final String id;
  final String taskId;
  final DateTime start;
  final DateTime end;

  ExecutionEntry({
    required this.id,
    required this.taskId,
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);

  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'taskId': taskId,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
    };
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'taskId': taskId,
      'start': start.toLocal().toIso8601String(),
      'end': end.toLocal().toIso8601String(),
    };
  }

  factory ExecutionEntry.fromMap(Map<String, dynamic> map) {
    return ExecutionEntry(
      id: map['id'] as String,
      taskId: map['taskId'] as String,
      start: map['start'] is Timestamp
          ? (map['start'] as Timestamp).toDate()
          : DateTime.parse(map['start']).toLocal(),
      end: map['end'] is Timestamp
          ? (map['end'] as Timestamp).toDate()
          : DateTime.parse(map['end']).toLocal(),
    );
  }
}
