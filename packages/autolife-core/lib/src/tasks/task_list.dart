import 'package:meta/meta.dart';

import 'task_smart_rule.dart';

@immutable
class TaskList {
  const TaskList({
    required this.id,
    required this.familyId,
    required this.name,
    this.iconName = 'list',
    this.colorHex,
    this.defaultAssigneeId,
    this.sharingScopeJson,
    this.isSmart = false,
    this.smartRule,
    this.position = 0,
    this.archived = false,
    this.defaultReminderMinutesBeforeDue = 15,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String familyId;
  final String name;
  final String iconName;
  final String? colorHex;
  final String? defaultAssigneeId;
  final Map<String, dynamic>? sharingScopeJson;

  final bool isSmart;
  final TaskSmartRule? smartRule;
  final int position;
  final bool archived;

  /// Default reminder offset (minutes before due) for quick-add when list has no overrides.
  final int? defaultReminderMinutesBeforeDue;

  final DateTime createdAt;
  final DateTime updatedAt;

  TaskList copyWith({
    String? id,
    String? familyId,
    String? name,
    String? iconName,
    String? colorHex,
    String? defaultAssigneeId,
    Map<String, dynamic>? sharingScopeJson,
    bool? isSmart,
    TaskSmartRule? smartRule,
    int? position,
    bool? archived,
    int? defaultReminderMinutesBeforeDue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TaskList(
    id: id ?? this.id,
    familyId: familyId ?? this.familyId,
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    colorHex: colorHex ?? this.colorHex,
    defaultAssigneeId: defaultAssigneeId ?? this.defaultAssigneeId,
    sharingScopeJson: sharingScopeJson ?? this.sharingScopeJson,
    isSmart: isSmart ?? this.isSmart,
    smartRule: smartRule ?? this.smartRule,
    position: position ?? this.position,
    archived: archived ?? this.archived,
    defaultReminderMinutesBeforeDue: defaultReminderMinutesBeforeDue ??
        this.defaultReminderMinutesBeforeDue,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'family_id': familyId,
    'name': name,
    'icon_name': iconName,
    if (colorHex != null) 'color_hex': colorHex,
    if (defaultAssigneeId != null) 'default_assignee_id': defaultAssigneeId,
    if (sharingScopeJson != null) 'sharing_scope': sharingScopeJson,
    'is_smart': isSmart,
    if (smartRule != null) 'smart_rule': smartRule!.toJson(),
    'position': position,
    'archived': archived,
    if (defaultReminderMinutesBeforeDue != null)
      'default_reminder_minutes_before_due': defaultReminderMinutesBeforeDue,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory TaskList.fromJson(Map<String, dynamic> json) {
    TaskSmartRule? rule;
    final rawRule = json['smart_rule'];
    if (rawRule is Map<String, dynamic>) {
      rule = TaskSmartRule.fromJson(rawRule);
    }
    return TaskList(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      name: json['name'] as String,
      iconName: json['icon_name'] as String? ?? 'list',
      colorHex: json['color_hex'] as String?,
      defaultAssigneeId: json['default_assignee_id']?.toString(),
      sharingScopeJson: json['sharing_scope'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['sharing_scope'] as Map)
          : null,
      isSmart: json['is_smart'] as bool? ?? false,
      smartRule: rule,
      position: (json['position'] as num?)?.toInt() ?? 0,
      archived: json['archived'] as bool? ?? false,
      defaultReminderMinutesBeforeDue:
          (json['default_reminder_minutes_before_due'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
