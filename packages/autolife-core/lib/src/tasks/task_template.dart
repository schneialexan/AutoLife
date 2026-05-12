import 'package:meta/meta.dart';

import 'task_priority.dart';
import 'task_step.dart';

/// Single blueprint row for [TaskTemplate].
@immutable
class TaskTemplateItem {
  const TaskTemplateItem({
    required this.title,
    this.description,
    this.priority = TaskPriority.medium,
    this.tags = const [],
    this.steps = const [],
    /// Minutes from anchor time when template is applied (due).
    this.dueOffsetMinutes,
    this.assigneeIds = const [],
    this.prerequisiteIndices = const [],
  });

  final String title;
  final String? description;
  final TaskPriority priority;
  final List<String> tags;
  final List<TaskStep> steps;
  final int? dueOffsetMinutes;
  final List<String> assigneeIds;

  /// Indices into the template's item list (before expansion) for DAG edges.
  final List<int> prerequisiteIndices;

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    'priority': priority.name,
    'tags': tags,
    'steps': steps.map((s) => s.toJson()).toList(),
    if (dueOffsetMinutes != null) 'due_offset_minutes': dueOffsetMinutes,
    'assignee_ids': assigneeIds,
    'prerequisite_indices': prerequisiteIndices,
  };

  factory TaskTemplateItem.fromJson(Map<String, dynamic> json) {
    final stepsRaw = json['steps'];
    final steps = <TaskStep>[];
    if (stepsRaw is List) {
      for (final e in stepsRaw) {
        if (e is Map<String, dynamic>) steps.add(TaskStep.fromJson(e));
      }
    }
    final prereq = json['prerequisite_indices'];
    final prereqList = <int>[];
    if (prereq is List) {
      for (final e in prereq) {
        if (e is num) prereqList.add(e.toInt());
      }
    }
    return TaskTemplateItem(
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      priority: taskPriorityFromWire(json['priority'] as String?) ??
          TaskPriority.medium,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      steps: steps,
      dueOffsetMinutes: (json['due_offset_minutes'] as num?)?.toInt(),
      assigneeIds:
          (json['assignee_ids'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      prerequisiteIndices: prereqList,
    );
  }
}

/// Template blueprint stored in `task_templates.tasks_blueprint`.
@immutable
class TaskTemplate {
  const TaskTemplate({
    required this.id,
    required this.familyId,
    required this.name,
    required this.items,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  final String id;
  final String familyId;
  final String name;
  final List<TaskTemplateItem> items;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  Map<String, dynamic> toJson() => {
    'id': id,
    'family_id': familyId,
    'name': name,
    'version': version,
    'tasks_blueprint': items.map((e) => e.toJson()).toList(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    if (createdBy != null) 'created_by': createdBy,
  };

  factory TaskTemplate.fromJson(Map<String, dynamic> json) {
    final raw = json['tasks_blueprint'];
    final items = <TaskTemplateItem>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          items.add(TaskTemplateItem.fromJson(e));
        }
      }
    }
    return TaskTemplate(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      name: json['name'] as String? ?? 'Template',
      items: items,
      version: (json['version'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by']?.toString(),
    );
  }
}
