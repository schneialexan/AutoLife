import 'dashboard_form_factor.dart';
import 'dashboard_layout.dart';
import 'dashboard_row.dart';
import 'dashboard_tile.dart';

/// Built-in Home layouts before persistence / family-default seeding (phase 3.1.5).
final Map<DashboardFormFactor, DashboardLayout> kDefaultDashboardLayouts = {
  DashboardFormFactor.mobile: DashboardLayout(
    schemaVersion: 2,
    base: [
      DashboardRow(
        heightUnits: 3,
        tiles: [DashboardTile(widgetId: 'today_summary', widthUnits: 6)],
      ),
      DashboardRow(
        heightUnits: 1,
        tiles: [DashboardTile(widgetId: 'family_avatar_strip', widthUnits: 6)],
      ),
      DashboardRow(
        heightUnits: 1,
        tiles: [DashboardTile(widgetId: 'quick_actions', widthUnits: 6)],
      ),
      DashboardRow(
        heightUnits: 3,
        tiles: [DashboardTile(widgetId: 'upcoming_strip', widthUnits: 6)],
      ),
      DashboardRow(
        heightUnits: 2,
        tiles: [DashboardTile(widgetId: 'activity_feed', widthUnits: 6)],
      ),
    ],
  ),
  DashboardFormFactor.tablet: DashboardLayout(
    schemaVersion: 2,
    base: [
      DashboardRow(
        heightUnits: 2,
        tiles: [
          DashboardTile(widgetId: 'today_summary', widthUnits: 4),
          DashboardTile(widgetId: 'family_avatar_strip', widthUnits: 2),
        ],
      ),
      DashboardRow(
        heightUnits: 1,
        tiles: [DashboardTile(widgetId: 'quick_actions', widthUnits: 6)],
      ),
      DashboardRow(
        heightUnits: 3,
        tiles: [
          DashboardTile(widgetId: 'upcoming_strip', widthUnits: 3),
          DashboardTile(widgetId: 'activity_feed', widthUnits: 3),
        ],
      ),
    ],
  ),
  DashboardFormFactor.desktop: DashboardLayout(
    schemaVersion: 2,
    base: [
      DashboardRow(
        heightUnits: 3,
        tiles: [
          DashboardTile(widgetId: 'today_summary', widthUnits: 3),
          DashboardTile(widgetId: 'upcoming_strip', widthUnits: 3),
        ],
      ),
      DashboardRow(
        heightUnits: 2,
        tiles: [
          DashboardTile(widgetId: 'family_avatar_strip', widthUnits: 3),
          DashboardTile(widgetId: 'activity_feed', widthUnits: 3),
        ],
      ),
      DashboardRow(
        heightUnits: 1,
        tiles: [DashboardTile(widgetId: 'quick_actions', widthUnits: 6)],
      ),
    ],
  ),
  DashboardFormFactor.web: DashboardLayout(
    schemaVersion: 2,
    base: [
      DashboardRow(
        heightUnits: 3,
        tiles: [
          DashboardTile(widgetId: 'today_summary', widthUnits: 3),
          DashboardTile(widgetId: 'upcoming_strip', widthUnits: 3),
        ],
      ),
      DashboardRow(
        heightUnits: 2,
        tiles: [
          DashboardTile(widgetId: 'family_avatar_strip', widthUnits: 3),
          DashboardTile(widgetId: 'activity_feed', widthUnits: 3),
        ],
      ),
      DashboardRow(
        heightUnits: 1,
        tiles: [DashboardTile(widgetId: 'quick_actions', widthUnits: 6)],
      ),
    ],
  ),
};

/// Back-compat: mobile-only default used when form factor is unavailable.
@Deprecated('Use kDefaultDashboardLayouts[DashboardFormFactor.mobile]')
DashboardLayout get kDefaultDashboardLayoutFallback =>
    kDefaultDashboardLayouts[DashboardFormFactor.mobile]!;
