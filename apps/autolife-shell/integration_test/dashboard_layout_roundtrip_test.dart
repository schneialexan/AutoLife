import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Lightweight integration guard: layout JSON with presentation fields.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('DashboardLayout presentation JSON round-trip', () {
    const scope = DashboardScope(
      formFactor: DashboardFormFactor.mobile,
      adaptive: DashboardAdaptiveMode.anyTime,
    );

    final doc = DashboardLayout(
      schemaVersion: 2,
      base: [
        DashboardRow(
          heightUnits: 1,
          tiles: [
            DashboardTile(widgetId: 'today_summary', widthUnits: 6),
          ],
        ),
      ],
      basePresentation: const DashboardPresentation(
        mode: DashboardOverflowMode.scrollVertical,
      ),
    );

    final enc = doc.toJson();
    final decoded = DashboardLayout.fromJson(enc);
    expect(
      decoded.resolvePresentation(scope).mode,
      DashboardOverflowMode.scrollVertical,
    );
  });
}
