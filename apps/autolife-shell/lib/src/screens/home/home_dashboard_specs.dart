import 'package:autolife_core/autolife_core.dart';

import 'widgets/activity_feed_widget.dart';
import 'widgets/family_avatar_strip.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/today_summary_card.dart';
import 'widgets/upcoming_strip.dart';

/// Registers built-in shell dashboard tiles (phase 3.1).
void registerHomeDashboardSpecs(DashboardWidgetRegistry registry) {
  registry.register(todaySummaryDashboardSpec);
  registry.register(familyAvatarStripDashboardSpec);
  registry.register(quickActionsDashboardSpec);
  registry.register(upcomingStripDashboardSpec);
  registry.register(activityFeedDashboardSpec);
}
