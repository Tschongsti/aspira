enum Status { active, inactive, deleted }
enum IconName { landscape, diversity_3, favorite}
enum Type { task, quantity, time }

abstract class TrackableTask {
  final String id;
  final String title;
  final String description;
  final IconName iconName;
  final DateTime startDate;
  final Status status;
  final Duration loggedTime;
  final bool isArchived;

  final DateTime updatedAt;
  final bool isDirty;

  final Type type;

  const TrackableTask({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.startDate,
    required this.status,
    required this.loggedTime,
    required this.isArchived,
    required this.updatedAt,
    required this.isDirty,
    required this.type,
  });

  String get parentCollection; // FokusTätigkeit, Gewohnheit, ToDo, ToRelax

  Map<String, dynamic> toLocalMap();
  factory TrackableTask.fromLocalMap(Map<String, dynamic> map) =>
      throw UnimplementedError('Implement in subclasses');
}