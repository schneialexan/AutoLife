import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/providers/external_sync_provider.dart';
import 'package:auto_calendar/src/screens/calendar/babysitter_link_screen.dart';
import 'package:auto_calendar/src/screens/calendar/import/calendar_import_screen.dart';
import 'package:auto_calendar/src/screens/calendar/quick_create_sheet.dart';
import 'package:auto_calendar/src/screens/calendar/views/agenda_view.dart';
import 'package:auto_calendar/src/screens/calendar/views/day_view.dart';
import 'package:auto_calendar/src/screens/calendar/views/month_view.dart';
import 'package:auto_calendar/src/screens/calendar/views/week_view.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({
    super.key,
    required this.familyId,
    this.showAppBar = true,
  });

  final String familyId;
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(calendarSelectedViewProvider);
    final anchor = ref.watch(calendarAnchorProvider);
    final isPhoneWeekToolbar = mode == CalendarViewMode.week &&
        MediaQuery.sizeOf(context).width < kCalendarWeekPhoneLayoutWidth;
    ref.listen(calendarQuickCreateSignalProvider, (p, n) {
      if (p != n && n > 0) {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (ctx) =>
              QuickCreateSheet(familyId: familyId),
        );
      }
    });
    ref.listen(calendarGoToTodaySignalProvider, (p, n) {
      if (p != n && n > 0) {
        ref.read(calendarAnchorProvider.notifier).state =
            DateTime.now().toUtc();
      }
    });

    final body = switch (mode) {
      CalendarViewMode.day => DayView(
        familyId: familyId,
        anchor: anchor,
      ),
      CalendarViewMode.week => WeekView(
        familyId: familyId,
        anchor: anchor,
      ),
      CalendarViewMode.month => MonthView(
        familyId: familyId,
        anchor: anchor,
      ),
      CalendarViewMode.agenda => AgendaView(
        familyId: familyId,
        anchor: anchor,
      ),
    };

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Calendar'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.today_outlined),
                  tooltip: 'Go to today',
                  onPressed: () {
                    ref.read(calendarGoToTodaySignalProvider.notifier).state++;
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cloud_sync_outlined),
                  tooltip: 'External sync',
                  onPressed: () {
                    ref.read(externalSyncControllerProvider.notifier).pullGoogle();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sync requested — connector refresh enqueued.')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.upload_file_outlined),
                  tooltip: 'Import',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          CalendarImportScreen(familyId: familyId),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.link_outlined),
                  tooltip: 'Babysitter link',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          BabysitterLinkScreen(familyId: familyId),
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AutoLifeSpacing.md,
              AutoLifeSpacing.sm,
              AutoLifeSpacing.md,
              AutoLifeSpacing.xs,
            ),
            child: SegmentedButton<CalendarViewMode>(
              segments: const [
                ButtonSegment(value: CalendarViewMode.day, label: Text('Day')),
                ButtonSegment(value: CalendarViewMode.week, label: Text('Week')),
                ButtonSegment(value: CalendarViewMode.month, label: Text('Month')),
                ButtonSegment(
                  value: CalendarViewMode.agenda,
                  label: Text('Agenda'),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (s) {
                ref.read(calendarSelectedViewProvider.notifier).setView(
                      s.first,
                    );
              },
            ),
          ),
          if (isPhoneWeekToolbar) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AutoLifeSpacing.md,
                0,
                AutoLifeSpacing.md,
                AutoLifeSpacing.xs,
              ),
              child: SegmentedButton<MobileWeekMode>(
                segments: const [
                  ButtonSegment<MobileWeekMode>(
                    value: MobileWeekMode.threeDaySwipe,
                    label: Text('2-day'),
                  ),
                  ButtonSegment<MobileWeekMode>(
                    value: MobileWeekMode.stackedAgenda,
                    label: Text('Agenda'),
                  ),
                ],
                selected: {ref.watch(calendarMobileWeekModeProvider)},
                onSelectionChanged: (s) {
                  ref.read(calendarMobileWeekModeProvider.notifier).setMode(
                        s.first,
                      );
                },
              ),
            ),
          ],
          Expanded(child: body),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Quick create',
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => QuickCreateSheet(familyId: familyId),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
