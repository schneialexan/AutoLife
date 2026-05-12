import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';

Color calendarEventAccentColor(
  CalendarEvent event,
  List<CalendarMemberSeed> seeds,
) {
  for (final m in seeds) {
    if (event.taggedMemberIds.contains(m.id)) {
      return Color(int.parse(m.colorHex.replaceFirst('#', '0xFF')));
    }
  }
  if (event.color != null) {
    try {
      return Color(int.parse(event.color!.replaceFirst('#', '0xFF')));
    } catch (_) {}
  }
  return Colors.blueGrey;
}
