import 'package:meta/meta.dart';

import 'task_priority.dart';

/// Closed-set smart list rule. Unknown JSON keys throw [FormatException].
@immutable
class TaskSmartRule {
  const TaskSmartRule({
    this.dueWithinDays,
    this.priorityAtLeast,
    this.tagsAny = const [],
    this.assigneeIdsAny = const [],
    this.sourceModuleIn = const [],
    this.listIdsAny = const [],
  });

  final int? dueWithinDays;
  final TaskPriority? priorityAtLeast;
  final List<String> tagsAny;
  final List<String> assigneeIdsAny;
  final List<String> sourceModuleIn;
  final List<String> listIdsAny;

  static const Set<String> kAllowedKeys = {
    'due_within_days',
    'priority_at_least',
    'tags_any',
    'assignee_ids_any',
    'source_module_in',
    'list_ids_any',
  };

  Map<String, dynamic> toJson() => {
    if (dueWithinDays != null) 'due_within_days': dueWithinDays,
    if (priorityAtLeast != null) 'priority_at_least': priorityAtLeast!.name,
    if (tagsAny.isNotEmpty) 'tags_any': tagsAny,
    if (assigneeIdsAny.isNotEmpty) 'assignee_ids_any': assigneeIdsAny,
    if (sourceModuleIn.isNotEmpty) 'source_module_in': sourceModuleIn,
    if (listIdsAny.isNotEmpty) 'list_ids_any': listIdsAny,
  };

  factory TaskSmartRule.fromJson(Map<String, dynamic> json) {
    for (final k in json.keys) {
      if (!kAllowedKeys.contains(k)) {
        throw FormatException('Unknown TaskSmartRule key: $k');
      }
    }
    final rawP = json['priority_at_least'] as String?;
    return TaskSmartRule(
      dueWithinDays: (json['due_within_days'] as num?)?.toInt(),
      priorityAtLeast: rawP == null
          ? null
          : taskPriorityFromWire(rawP),
      tagsAny: _stringList(json['tags_any']),
      assigneeIdsAny: _stringList(json['assignee_ids_any']),
      sourceModuleIn: _stringList(json['source_module_in']),
      listIdsAny: _stringList(json['list_ids_any']),
    );
  }

  static List<String> _stringList(Object? raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }
}