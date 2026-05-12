import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DashboardLayout v1 migrates to rows and round-trips JSON', () {
    const v1 = DashboardLayout(
      schemaVersion: 1,
      slots: [
        DashboardSlot(
          widgetId: 'a',
          requestedSize: DashboardSize.s,
        ),
        DashboardSlot(
          widgetId: 'b',
          requestedSize: DashboardSize.s,
        ),
        DashboardSlot(
          widgetId: 'c',
          requestedSize: DashboardSize.m,
        ),
      ],
    );
    final v2 = v1.migrateToV2();
    expect(v2.schemaVersion, 2);
    expect(v2.base.isNotEmpty, isTrue);

    final json = v2.toJson();
    final back = DashboardLayout.fromJson(json);
    expect(back.schemaVersion, 2);
    expect(back.base.length, v2.base.length);
  });

  test('resolveRows applies overrides with anyTime fallback', () {
    const baseRows = [
      DashboardRow(
        heightUnits: 1,
        tiles: [DashboardTile(widgetId: 'only', widthUnits: 6)],
      ),
    ];
    final layout = DashboardLayout(
      schemaVersion: 2,
      base: baseRows,
      rowOverrides: {
        'mobile:anyTime': const [
          DashboardRow(
            heightUnits: 1,
            tiles: [DashboardTile(widgetId: 'mob', widthUnits: 6)],
          ),
        ],
        'mobile:evening': const [
          DashboardRow(
            heightUnits: 1,
            tiles: [DashboardTile(widgetId: 'eve', widthUnits: 6)],
          ),
        ],
      },
    );
    final evening = layout.resolveRows(
      const DashboardScope(
        formFactor: DashboardFormFactor.mobile,
        adaptive: DashboardAdaptiveMode.evening,
      ),
    );
    expect(evening.single.tiles.single.widgetId, 'eve');

    final morning = layout.resolveRows(
      const DashboardScope(
        formFactor: DashboardFormFactor.mobile,
        adaptive: DashboardAdaptiveMode.morning,
      ),
    );
    expect(morning.single.tiles.single.widgetId, 'mob');
  });
}

