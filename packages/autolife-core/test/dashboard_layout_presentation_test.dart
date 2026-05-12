import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardLayout presentation', () {
    const scope = DashboardScope(
      formFactor: DashboardFormFactor.mobile,
      adaptive: DashboardAdaptiveMode.morning,
    );

    test('resolvePresentation falls back to base', () {
      const pres = DashboardPresentation(
        mode: DashboardOverflowMode.scrollVertical,
      );
      final doc = DashboardLayout(
        schemaVersion: 2,
        base: [
          DashboardRow(
            heightUnits: 1,
            tiles: [DashboardTile(widgetId: 'a', widthUnits: 6)],
          ),
        ],
        basePresentation: pres,
      );
      expect(doc.resolvePresentation(scope).mode, DashboardOverflowMode.scrollVertical);
    });

    test('withPresentationForScope this scope only', () {
      final doc = DashboardLayout(
        schemaVersion: 2,
        base: [
          DashboardRow(
            heightUnits: 1,
            tiles: [DashboardTile(widgetId: 'a', widthUnits: 6)],
          ),
          DashboardRow(
            heightUnits: 1,
            tiles: [DashboardTile(widgetId: 'b', widthUnits: 6)],
          ),
        ],
      );
      final next = doc.withPresentationForScope(
        presentation: const DashboardPresentation(
          mode: DashboardOverflowMode.boards,
          boardBreaks: [1],
        ),
        scope: scope,
        editAllScopes: false,
        rowCountForNormalization: 2,
      );
      expect(
        next.presentationOverrides[scope.cacheKey]?.mode,
        DashboardOverflowMode.boards,
      );
      expect(next.basePresentation.mode, DashboardOverflowMode.autoFit);
    });

    test('round-trip JSON without presentation keeps default', () {
      final doc = DashboardLayout.fromJson({
        'schema': 2,
        'base': [
          {
            'height_units': 1,
            'tiles': [
              {'widget_id': 'x', 'width_units': 6},
            ],
          },
        ],
        'overrides': <String, dynamic>{},
      });
      expect(doc.basePresentation.mode, DashboardOverflowMode.autoFit);
      final round = DashboardLayout.fromJson(doc.toJson());
      expect(round.basePresentation.mode, DashboardOverflowMode.autoFit);
    });

    test('toJson includes presentation when non-default', () {
      final doc = DashboardLayout(
        schemaVersion: 2,
        base: [
          DashboardRow(
            heightUnits: 1,
            tiles: [DashboardTile(widgetId: 'a', widthUnits: 6)],
          ),
        ],
        basePresentation: const DashboardPresentation(
          mode: DashboardOverflowMode.scrollSnap,
        ),
      );
      final j = doc.toJson();
      expect(j['presentation'], isNotNull);
      final back = DashboardLayout.fromJson(j);
      expect(back.basePresentation.mode, DashboardOverflowMode.scrollSnap);
    });
  });
}
