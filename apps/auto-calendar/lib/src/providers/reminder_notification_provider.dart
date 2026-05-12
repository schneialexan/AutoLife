import 'package:auto_calendar/src/services/reminder_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reminderNotificationServiceProvider =
    Provider<ReminderNotificationService>((ref) {
  return ReminderNotificationService();
});
