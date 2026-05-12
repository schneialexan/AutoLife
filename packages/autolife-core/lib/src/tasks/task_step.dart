import 'package:meta/meta.dart';

/// Sub-task step (Microsoft To-Do "Steps") — does not gate parent completion.
@immutable
class TaskStep {
  const TaskStep({
    required this.id,
    required this.title,
    this.done = false,
  });

  final String id;
  final String title;
  final bool done;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'done': done,
  };

  factory TaskStep.fromJson(Map<String, dynamic> json) {
    return TaskStep(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      done: json['done'] as bool? ?? false,
    );
  }

  TaskStep copyWith({String? id, String? title, bool? done}) => TaskStep(
    id: id ?? this.id,
    title: title ?? this.title,
    done: done ?? this.done,
  );
}
