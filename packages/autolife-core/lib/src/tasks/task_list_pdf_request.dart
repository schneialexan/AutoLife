import 'package:meta/meta.dart';

/// PDF export request DTO for phase 3.14 `pdf-render` edge function.
@immutable
class TaskListPdfRequest {
  const TaskListPdfRequest({
    required this.familyId,
    required this.listId,
    this.templateId = 'minimal',
  });

  final String familyId;
  final String listId;
  final String templateId;

  Map<String, dynamic> toJson() => {
    'family_id': familyId,
    'list_id': listId,
    'template_id': templateId,
  };
}
