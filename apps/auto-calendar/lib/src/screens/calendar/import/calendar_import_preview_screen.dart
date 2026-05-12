import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/services/calendar_import_service.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class CalendarImportPreviewScreen extends ConsumerWidget {
  const CalendarImportPreviewScreen({
    super.key,
      required this.familyId,
    required this.preview,
  });

  final String familyId;
  final CalendarImportPreview preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(calendarRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Import preview')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${preview.eventCount} events · ${preview.duplicatesSkipped} skipped '
            '(idempotent) · source ${preview.source}',
          ),
          if (preview.unsupportedFields.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Unsupported fields carried to summary: '
              '${preview.unsupportedFields.join(', ')}',
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              for (final e in preview.events) {
                await repo.upsert(
                  CalendarEvent(
                    id: const Uuid().v4(),
                    familyId: familyId,
                    title: e.title,
                    startAt: e.startAt,
                    endAt: e.endAt,
                    allDay: false,
                    createdBy: '11111111-1111-1111-1111-111111111111',
                    syncSource: 'ics_import',
                    provider: 'ics',
                    externalUid: e.externalUid,
                    createdAt: DateTime.now().toUtc(),
                    updatedAt: DateTime.now().toUtc(),
                  ),
                );
              }
              if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: const Text('Commit import'),
          ),
        ],
      ),
    );
  }
}
