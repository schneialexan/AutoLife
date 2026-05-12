import 'package:flutter/widgets.dart';

import 'dashboard_layout.dart';
import 'dashboard_size.dart';

/// Builds the Flutter subtree for one dashboard tile.
typedef DashboardTileBuilder =
    Widget Function(BuildContext context, DashboardSlot slot);

/// Registered shell/module dashboard widget (phase 3.1).
///
/// Modules register via `DashboardWidgetRegistry.register` so `autolife-shell`
/// never imports module internals.
class DashboardWidgetSpec {
  const DashboardWidgetSpec({
    required this.widgetId,
    required this.moduleId,
    required this.title,
    required this.supportedSizes,
    required this.build,
    this.minWidthUnits,
    this.minHeightUnits,
  });

  /// Stable id referenced by [DashboardSlot.widgetId].
  final String widgetId;

  /// Logical owning module (`shell`, `calendar`, `tasks`, …).
  final String moduleId;

  /// Debug / picker label.
  final String title;

  /// Sizes this widget can render; host clamps unsupported requests.
  ///
  /// Phase 3.1 grid hints; the viewport-flex host (3.1.5) uses [minWidthUnits].
  final List<DashboardSize> supportedSizes;

  /// Minimum width flex units (1–6) for 3.1.5 rows; optional.
  final int? minWidthUnits;

  /// Minimum row height flex hint; optional.
  final int? minHeightUnits;

  final DashboardTileBuilder build;

  /// Smallest span among [supportedSizes] (enumeration order).
  DashboardSize get smallestSupportedSize =>
      supportedSizes.reduce((a, b) => a.index <= b.index ? a : b);
}

/// Chooses an allowed size for [requested], falling back to smallest supported.
DashboardSize resolveEffectiveSize(
  DashboardWidgetSpec spec,
  DashboardSize requested,
) {
  if (spec.supportedSizes.contains(requested)) return requested;
  return spec.smallestSupportedSize;
}
