import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/screens/home/edit_mode/edit_layout_ops.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scope = DashboardScope(
    formFactor: DashboardFormFactor.mobile,
    adaptive: DashboardAdaptiveMode.anyTime,
  );

  DashboardLayout twoTileRowDoc() {
    return DashboardLayout(
      schemaVersion: 2,
      base: [
        DashboardRow(
          heightUnits: 2,
          tiles: [
            DashboardTile(widgetId: 'a', widthUnits: 4),
            DashboardTile(widgetId: 'b', widthUnits: 2),
          ],
        ),
      ],
    );
  }

  test('reorderRow reverses two rows', () {
    final doc = DashboardLayout(
      schemaVersion: 2,
      base: [
        DashboardRow(
          heightUnits: 1,
          tiles: [DashboardTile(widgetId: 'first', widthUnits: 6)],
        ),
        DashboardRow(
          heightUnits: 1,
          tiles: [DashboardTile(widgetId: 'second', widthUnits: 6)],
        ),
      ],
    );
    final next = reorderRow(doc, scope, true, 0, 1);
    final ids = next.resolveRows(scope).map((r) => r.tiles.single.widgetId).toList();
    expect(ids, ['second', 'first']);
  });

  test('bumpTileWidthDelta respects minimums', () {
    final doc = twoTileRowDoc();
    int minw(String _) => 2;
    final widened =
        bumpTileWidthDelta(doc, scope, true, 0, 1, -1, minWidthUnitsOf: minw);
    final tiles = widened.resolveRows(scope).first.tiles;
    expect(tiles[1].widthUnits, greaterThanOrEqualTo(2));
  });

  test('detachTileIntoNewRow inserts lone full-width row', () {
    final doc = twoTileRowDoc();
    final next = detachTileIntoNewRow(doc, scope, true, 0, 1, 1);
    final rows = next.resolveRows(scope);
    expect(rows.length, greaterThanOrEqualTo(2));
    expect(rows[1].tiles.single.widthUnits, 6);
  });

  test('moveTileCrossRow returns null when cannot fit min width', () {
    final doc = DashboardLayout(
      schemaVersion: 2,
      base: [
        DashboardRow(
          heightUnits: 1,
          tiles: [DashboardTile(widgetId: 'a', widthUnits: 6)],
        ),
        DashboardRow(
          heightUnits: 1,
          tiles: [
            DashboardTile(widgetId: 'b', widthUnits: 5),
            DashboardTile(widgetId: 'c', widthUnits: 1),
          ],
        ),
      ],
    );
    int minwBig(String _) => 4;
    final fail = moveTileCrossRow(
      doc,
      scope,
      true,
      fromRow: 0,
      fromTile: 0,
      toRow: 1,
      insertTileIndex: 0,
      minWidthUnitsOf: minwBig,
    );
    expect(fail, isNull);
  });
}
