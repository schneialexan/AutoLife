import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/calendar_screen.dart';
import 'package:auto_calendar/src/seed/demo_calendar_seed.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Embeddable calendar module (shell can wrap with its own [ProviderScope]).
class CalendarModule extends ConsumerStatefulWidget {
  const CalendarModule({
    super.key,
    required this.familyId,
    this.showAppBar = true,
  });

  final String familyId;
  final bool showAppBar;

  @override
  ConsumerState<CalendarModule> createState() => _CalendarModuleState();
}

class _CalendarModuleState extends ConsumerState<CalendarModule> {
  var _seeded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_seeded) return;
      final repo = ref.read(calendarRepositoryProvider);
      if (repo is MemoryCalendarRepository) {
        repo.seed(demoCalendarEvents(widget.familyId));
        _seeded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalendarScreen(
      familyId: widget.familyId,
      showAppBar: widget.showAppBar,
    );
  }
}
