import 'package:meta/meta.dart';

@immutable
class TaskDependency {
  const TaskDependency({
    required this.id,
    required this.familyId,
    required this.taskId,
    required this.prerequisiteTaskId,
    required this.createdAt,
  });

  final String id;
  final String familyId;
  final String taskId;
  final String prerequisiteTaskId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'family_id': familyId,
    'task_id': taskId,
    'prerequisite_task_id': prerequisiteTaskId,
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  factory TaskDependency.fromJson(Map<String, dynamic> json) {
    return TaskDependency(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      taskId: json['task_id'] as String,
      prerequisiteTaskId: json['prerequisite_task_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
