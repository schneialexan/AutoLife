import 'package:meta/meta.dart';

import '../calendar/calendar_recurrence.dart';
import 'task_attachment.dart';
import 'task_link.dart';
import 'task_priority.dart';
import 'task_reminder.dart';
import 'task_status.dart';
import 'task_step.dart';

/// Sentinel for [Task.copyWith]: omit field to keep previous value.
class TaskCopyUnset {
  const TaskCopyUnset();
}

/// Default for optional parameters in [Task.copyWith].
const taskCopyUnset = TaskCopyUnset();

/// Row shape for `tasks` (PostgREST + local cache).
@immutable
class Task {
  const Task({
    required this.id,
    required this.familyId,
    required this.listId,
    required this.title,
    required this.status,
    required this.priority,
    required this.importance,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.dueAt,
    this.scheduledFor,
    this.estimatedDuration,
    this.myDayDate,
    this.reminders = const [],
    this.recurrenceRule,
    this.seriesId,
    this.exceptionOriginalDue,
    this.steps = const [],
    this.tags = const [],
    this.attachments = const [],
    this.links = const [],
    this.assigneeIds = const [],
    this.commentsCount = 0,
    this.relatedAssetIds = const [],
    this.relatedEventIds = const [],
    this.sourceEventId,
    this.scheduledEventId,
    this.sourceTaskId,
    this.sourceModule,
    this.completedAt,
    this.completedBy,
    this.canceledAt,
    this.canceledBy,
    this.color,
    this.requiresApproval = false,
  });

  final String id;
  final String familyId;
  final String listId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  /// Star / "Important" flag (To-Do); not the same as [priority].
  final bool importance;

  final DateTime? dueAt;
  final DateTime? scheduledFor;
  final Duration? estimatedDuration;

  /// Local date bucket for My Day (start-of-day semantics in client TZ).
  final DateTime? myDayDate;

  final List<TaskReminder> reminders;
  final CalendarRecurrenceRule? recurrenceRule;
  final String? seriesId;
  final DateTime? exceptionOriginalDue;

  final List<TaskStep> steps;
  final List<String> tags;
  final List<TaskAttachment> attachments;
  final List<TaskLink> links;
  final List<String> assigneeIds;
  final int commentsCount;
  final List<String> relatedAssetIds;
  final List<String> relatedEventIds;

  final String? sourceEventId;
  final String? scheduledEventId;
  /// When an event was created from this task via promote.
  final String? sourceTaskId;
  final String? sourceModule;

  final DateTime? completedAt;
  final String? completedBy;
  final DateTime? canceledAt;
  final String? canceledBy;

  final String? color;
  final bool requiresApproval;

  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool assigneeIncludes(String userId) => assigneeIds.contains(userId);

  Task copyWith({
    String? id,
    String? familyId,
    String? listId,
    String? title,
    Object? description = taskCopyUnset,
    TaskStatus? status,
    TaskPriority? priority,
    bool? importance,
    Object? dueAt = taskCopyUnset,
    Object? scheduledFor = taskCopyUnset,
    Object? estimatedDuration = taskCopyUnset,
    Object? myDayDate = taskCopyUnset,
    List<TaskReminder>? reminders,
    Object? recurrenceRule = taskCopyUnset,
    Object? seriesId = taskCopyUnset,
    Object? exceptionOriginalDue = taskCopyUnset,
    List<TaskStep>? steps,
    List<String>? tags,
    List<TaskAttachment>? attachments,
    List<TaskLink>? links,
    List<String>? assigneeIds,
    int? commentsCount,
    List<String>? relatedAssetIds,
    List<String>? relatedEventIds,
    Object? sourceEventId = taskCopyUnset,
    Object? scheduledEventId = taskCopyUnset,
    Object? sourceTaskId = taskCopyUnset,
    Object? sourceModule = taskCopyUnset,
    Object? completedAt = taskCopyUnset,
    Object? completedBy = taskCopyUnset,
    Object? canceledAt = taskCopyUnset,
    Object? canceledBy = taskCopyUnset,
    Object? color = taskCopyUnset,
    bool? requiresApproval,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    String? pickStr(Object? v, String? current) =>
        identical(v, taskCopyUnset) ? current : v as String?;
    DateTime? pickDt(Object? v, DateTime? current) =>
        identical(v, taskCopyUnset) ? current : v as DateTime?;
    Duration? pickDur(Object? v, Duration? current) =>
        identical(v, taskCopyUnset) ? current : v as Duration?;
    CalendarRecurrenceRule? pickRec(
      Object? v,
      CalendarRecurrenceRule? current,
    ) => identical(v, taskCopyUnset) ? current : v as CalendarRecurrenceRule?;

    return Task(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      description: pickStr(description, this.description),
      status: status ?? this.status,
      priority: priority ?? this.priority,
      importance: importance ?? this.importance,
      dueAt: pickDt(dueAt, this.dueAt),
      scheduledFor: pickDt(scheduledFor, this.scheduledFor),
      estimatedDuration: pickDur(estimatedDuration, this.estimatedDuration),
      myDayDate: pickDt(myDayDate, this.myDayDate),
      reminders: reminders ?? this.reminders,
      recurrenceRule: pickRec(recurrenceRule, this.recurrenceRule),
      seriesId: pickStr(seriesId, this.seriesId),
      exceptionOriginalDue: pickDt(exceptionOriginalDue, this.exceptionOriginalDue),
      steps: steps ?? this.steps,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      links: links ?? this.links,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      commentsCount: commentsCount ?? this.commentsCount,
      relatedAssetIds: relatedAssetIds ?? this.relatedAssetIds,
      relatedEventIds: relatedEventIds ?? this.relatedEventIds,
      sourceEventId: pickStr(sourceEventId, this.sourceEventId),
      scheduledEventId: pickStr(scheduledEventId, this.scheduledEventId),
      sourceTaskId: pickStr(sourceTaskId, this.sourceTaskId),
      sourceModule: pickStr(sourceModule, this.sourceModule),
      completedAt: pickDt(completedAt, this.completedAt),
      completedBy: pickStr(completedBy, this.completedBy),
      canceledAt: pickDt(canceledAt, this.canceledAt),
      canceledBy: pickStr(canceledBy, this.canceledBy),
      color: pickStr(color, this.color),
      requiresApproval: requiresApproval ?? this.requiresApproval,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'family_id': familyId,
    'list_id': listId,
    'title': title,
    if (description != null) 'description': description,
    'status': status.name,
    'priority': priority.name,
    'importance': importance,
    'due_at': dueAt?.toUtc().toIso8601String(),
    'scheduled_for': scheduledFor?.toUtc().toIso8601String(),
    'estimated_duration_ms': estimatedDuration?.inMilliseconds,
    'my_day_date': myDayDate == null
        ? null
        : '${myDayDate!.year.toString().padLeft(4, '0')}-'
            '${myDayDate!.month.toString().padLeft(2, '0')}-'
            '${myDayDate!.day.toString().padLeft(2, '0')}',
    'reminders': reminders.map((e) => e.toJson()).toList(),
    'recurrence': recurrenceRule?.toJson(),
    'series_id': seriesId,
    'exception_original_due':
        exceptionOriginalDue?.toUtc().toIso8601String(),
    'steps': steps.map((e) => e.toJson()).toList(),
    'tags': tags,
    'attachments': attachments.map((e) => e.toJson()).toList(),
    'links': links.map((e) => e.toJson()).toList(),
    'assignee_ids': assigneeIds,
    'comments_count': commentsCount,
    'related_asset_ids': relatedAssetIds,
    'related_event_ids': relatedEventIds,
    'source_event_id': sourceEventId,
    'scheduled_event_id': scheduledEventId,
    'source_task_id': sourceTaskId,
    'source_module': sourceModule,
    'completed_at': completedAt?.toUtc().toIso8601String(),
    'completed_by': completedBy,
    'canceled_at': canceledAt?.toUtc().toIso8601String(),
    'canceled_by': canceledBy,
    'color': color,
    'requires_approval': requiresApproval,
    'created_by': createdBy,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    DateTime? parseTs(String? s) =>
        s == null || s.isEmpty ? null : DateTime.parse(s);

    CalendarRecurrenceRule? rec;
    final rawRec = json['recurrence'];
    if (rawRec is Map<String, dynamic>) {
      rec = CalendarRecurrenceRule.fromJson(rawRec);
    }

    DateTime? myDay;
    final rawMy = json['my_day_date'] as String?;
    if (rawMy != null && rawMy.isNotEmpty) {
      final parts = rawMy.split('-');
      if (parts.length == 3) {
        myDay = DateTime.utc(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }

    final steps = <TaskStep>[];
    final rawSteps = json['steps'];
    if (rawSteps is List) {
      for (final e in rawSteps) {
        if (e is Map<String, dynamic>) steps.add(TaskStep.fromJson(e));
      }
    }
    final reminders = <TaskReminder>[];
    final rawRem = json['reminders'];
    if (rawRem is List) {
      for (final e in rawRem) {
        if (e is Map<String, dynamic>) reminders.add(TaskReminder.fromJson(e));
      }
    }
    final att = <TaskAttachment>[];
    final rawAtt = json['attachments'];
    if (rawAtt is List) {
      for (final e in rawAtt) {
        if (e is Map<String, dynamic>) att.add(TaskAttachment.fromJson(e));
      }
    }
    final lnks = <TaskLink>[];
    final rawL = json['links'];
    if (rawL is List) {
      for (final e in rawL) {
        if (e is Map<String, dynamic>) lnks.add(TaskLink.fromJson(e));
      }
    }

    final durMs = (json['estimated_duration_ms'] as num?)?.toInt();

    return Task(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      listId: json['list_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: taskStatusFromWire(json['status'] as String? ?? 'inbox'),
      priority: taskPriorityFromWire(json['priority'] as String?) ??
          TaskPriority.medium,
      importance: json['importance'] as bool? ?? false,
      dueAt: parseTs(json['due_at'] as String?),
      scheduledFor: parseTs(json['scheduled_for'] as String?),
      estimatedDuration:
          durMs == null ? null : Duration(milliseconds: durMs),
      myDayDate: myDay,
      reminders: reminders,
      recurrenceRule: rec,
      seriesId: json['series_id'] as String?,
      exceptionOriginalDue: parseTs(json['exception_original_due'] as String?),
      steps: steps,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      attachments: att,
      links: lnks,
      assigneeIds:
          (json['assignee_ids'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      relatedAssetIds: (json['related_asset_ids'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      relatedEventIds: (json['related_event_ids'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sourceEventId: json['source_event_id'] as String?,
      scheduledEventId: json['scheduled_event_id'] as String?,
      sourceTaskId: json['source_task_id'] as String?,
      sourceModule: json['source_module'] as String?,
      completedAt: parseTs(json['completed_at'] as String?),
      completedBy: json['completed_by']?.toString(),
      canceledAt: parseTs(json['canceled_at'] as String?),
      canceledBy: json['canceled_by']?.toString(),
      color: json['color'] as String?,
      requiresApproval: json['requires_approval'] as bool? ?? false,
      createdBy: json['created_by'].toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
