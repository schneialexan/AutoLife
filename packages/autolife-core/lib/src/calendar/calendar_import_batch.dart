import 'package:meta/meta.dart';

/// Summary row for `.ics` / provider calendar imports (`calendar_import_batches`).
@immutable
class CalendarImportBatch {
  const CalendarImportBatch.n({
    required this.id,
    required this.familyId,
    required this.source,
    required this.idempotencyKey,
    required this.status,
    required this.summary,
    required this.unsupportedFields,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String familyId;
  final String source;
  final String idempotencyKey;
  final String status;
  final Map<String, dynamic> summary;
  final List<String> unsupportedFields;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CalendarImportBatch.fromMap(Map<String, dynamic> m) {
    List<String> uf = const [];
    final raw = m['unsupported_fields'];
    if (raw is List) {
      uf = raw.map((e) => e.toString()).toList();
    }
    final sum = m['summary'];
    return CalendarImportBatch.n(
      id: m['id'] as String,
      familyId: m['family_id'] as String,
      source: m['source'] as String,
      idempotencyKey: m['idempotency_key'] as String,
      status: m['status'] as String? ?? 'pending',
      summary: sum is Map<String, dynamic> ? sum : {},
      unsupportedFields: uf,
      createdBy: m['created_by'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
    );
  }
}
