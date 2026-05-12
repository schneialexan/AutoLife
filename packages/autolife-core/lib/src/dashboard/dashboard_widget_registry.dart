import 'dashboard_widget_spec.dart';

/// In-memory registry populated at bootstrap (phase 3.1).
class DashboardWidgetRegistry {
  final Map<String, DashboardWidgetSpec> _byId = {};

  void register(DashboardWidgetSpec spec) {
    if (_byId.containsKey(spec.widgetId)) {
      throw StateError('Duplicate dashboard widget id: ${spec.widgetId}');
    }
    _byId[spec.widgetId] = spec;
  }

  DashboardWidgetSpec? lookup(String widgetId) => _byId[widgetId];

  Iterable<DashboardWidgetSpec> get all => _byId.values;

  bool contains(String widgetId) => _byId.containsKey(widgetId);
}
