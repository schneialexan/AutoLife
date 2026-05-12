import 'package:flutter/material.dart';

/// Placeholder: pick calendar slot and call [TaskCalendarBridge.scheduleTaskBlock].
Future<void> showScheduleIntoCalendarSheet(
  BuildContext context, {
  required dynamic task,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Schedule into calendar — wire bridge + calendar picker in shell.'),
      ),
    ),
  );
}
