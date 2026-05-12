import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolveEffectiveSize falls back to smallest supported', () {
    final spec = DashboardWidgetSpec(
      widgetId: 't',
      moduleId: 'shell',
      title: 'T',
      supportedSizes: const [DashboardSize.s, DashboardSize.m],
      build: (context, slot) => throw UnimplementedError(),
    );

    expect(
      resolveEffectiveSize(spec, DashboardSize.xl),
      DashboardSize.s,
    );
    expect(
      resolveEffectiveSize(spec, DashboardSize.m),
      DashboardSize.m,
    );
  });
}
