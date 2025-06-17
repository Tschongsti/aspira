class ExecutionEntry {
  final String id;
  final String taskId;
  final DateTime start;
  final DateTime end;

  final bool isDirty;
  final bool isArchived;
  final DateTime updatedAt;

  ExecutionEntry({
    required this.id,
    required this.taskId,
    required this.start,
    required this.end,
    this.isDirty = true,
    this.isArchived = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Duration get duration => end.difference(start);

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'taskId': taskId,
      'start': start.toLocal().toIso8601String(),
      'end': end.toLocal().toIso8601String(),
      'isDirty': isDirty ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
      'updatedAt': updatedAt.toLocal().toIso8601String(),
    };
  }

  factory ExecutionEntry.fromLocalMap(Map<String, dynamic> map) {
    return ExecutionEntry(
      id: map['id'],
      taskId: map['taskId'],
      start: DateTime.parse(map['start']).toLocal(),
      end: DateTime.parse(map['end']).toLocal(),
      isDirty: (map['isDirty'] ?? 1) == 1,
      isArchived: (map['isArchived'] ?? 0) == 1,
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  ExecutionEntry copyWith({
    String? id,
    String? taskId,
    DateTime? start,
    DateTime? end,
    bool? isDirty,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return ExecutionEntry(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      start: start ?? this.start,
      end: end ?? this.end,
      isDirty: isDirty ?? this.isDirty,
      isArchived: isArchived ?? this.isArchived,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
