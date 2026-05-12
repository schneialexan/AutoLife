import 'package:autolife_core/autolife_core.dart';

typedef MinWidthUnitsOf = int Function(String widgetId);

typedef MinHeightUnitsOf = int Function(String widgetId);

int defaultMinFlex(String _) => 1;

/// Remove one tile; drops empty rows (phase 3.1.5 edit helpers).
DashboardLayout removeDashboardTileAt(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  int rowIndex,
  int tileIndex,
) {
  final v2 = doc.migrateToV2();
  final rows = DashboardLayout.cloneRows(v2.resolveRows(scope));
  if (rowIndex < 0 || rowIndex >= rows.length) return doc;
  final row = rows[rowIndex];
  if (tileIndex < 0 || tileIndex >= row.tiles.length) return doc;
  final newTiles = List<DashboardTile>.from(row.tiles)..removeAt(tileIndex);
  if (newTiles.isEmpty) {
    rows.removeAt(rowIndex);
  } else {
    rows[rowIndex] = DashboardRow(
      heightUnits: row.heightUnits,
      minHeightPx: row.minHeightPx,
      tiles: newTiles,
    );
  }
  return v2.withRowsForScope(
    rows: rows,
    scope: scope,
    editAllScopes: editAllScopes,
  );
}

/// Append a full-width row with [widgetId] at the bottom.
DashboardLayout appendDashboardWidget(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  String widgetId,
) {
  final v2 = doc.migrateToV2();
  final rows = DashboardLayout.cloneRows(v2.resolveRows(scope));
  rows.add(
    DashboardRow(
      heightUnits: 1,
      tiles: [
        DashboardTile(widgetId: widgetId, widthUnits: 6),
      ],
    ),
  );
  return v2.withRowsForScope(
    rows: rows,
    scope: scope,
    editAllScopes: editAllScopes,
  );
}

DashboardLayout reorderRow(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  int oldIndex,
  int newIndex,
) {
  final v2 = doc.migrateToV2();
  final rows = DashboardLayout.cloneRows(v2.resolveRows(scope));
  if (oldIndex < 0 ||
      oldIndex >= rows.length ||
      newIndex < 0 ||
      newIndex >= rows.length) {
    return doc;
  }
  final moved = rows.removeAt(oldIndex);
  rows.insert(newIndex, moved);
  return v2.withRowsForScope(
    rows: rows,
    scope: scope,
    editAllScopes: editAllScopes,
  );
}

DashboardLayout reorderTileInRow(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  int rowIdx,
  int oldTileIdx,
  int newTileIdx,
) {
  final v2 = doc.migrateToV2();
  final rows = DashboardLayout.cloneRows(v2.resolveRows(scope));
  if (rowIdx < 0 || rowIdx >= rows.length) return doc;
  final row = rows[rowIdx];
  final tiles = List<DashboardTile>.from(row.tiles);
  if (oldTileIdx < 0 ||
      oldTileIdx >= tiles.length ||
      newTileIdx < 0 ||
      newTileIdx >= tiles.length) {
    return doc;
  }
  if (oldTileIdx == newTileIdx) return doc;
  final item = tiles.removeAt(oldTileIdx);
  tiles.insert(oldTileIdx < newTileIdx ? newTileIdx - 1 : newTileIdx, item);
  rows[rowIdx] = DashboardRow(
    heightUnits: row.heightUnits,
    minHeightPx: row.minHeightPx,
    tiles: tiles,
  );
  return v2.withRowsForScope(
    rows: rows,
    scope: scope,
    editAllScopes: editAllScopes,
  );
}

DashboardLayout insertNewRowWithTile(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  int atRowIndex,
  DashboardTile tile, {
  int heightUnits = 1,
  MinWidthUnitsOf minWidthUnitsOf = defaultMinFlex,
}) {
  final v2 = doc.migrateToV2();
  final rows = DashboardLayout.cloneRows(v2.resolveRows(scope));
  final idx = atRowIndex.clamp(0, rows.length);
  final minW = minWidthUnitsOf(tile.widgetId).clamp(1, 6);
  final w = tile.widthUnits.clamp(minW, 6);
  rows.insert(
    idx,
    DashboardRow(
      heightUnits: heightUnits.clamp(1, 6),
      minHeightPx: null,
      tiles: [
        DashboardTile(
          widgetId: tile.widgetId,
          widthUnits: w,
          spanRows: tile.spanRows,
          minHeightPx: tile.minHeightPx,
        ),
      ],
    ),
  );
  return v2.withRowsForScope(
    rows: rows,
    scope: scope,
    editAllScopes: editAllScopes,
  );
}

/// Returns `null` if the tile cannot fit at its minimum width.
DashboardLayout? moveTileCrossRow(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes, {
  required int fromRow,
  required int fromTile,
  required int toRow,
  required int insertTileIndex,
  MinWidthUnitsOf minWidthUnitsOf = defaultMinFlex,
}) {
  final v2 = doc.migrateToV2();
  final rows = DashboardLayout.cloneRows(v2.resolveRows(scope));
  if (fromRow < 0 || fromRow >= rows.length) return null;
  final source = rows[fromRow];
  if (fromTile < 0 || fromTile >= source.tiles.length) return null;

  final moving = source.tiles[fromTile];
  final minMoving = minWidthUnitsOf(moving.widgetId).clamp(1, 6);

  final newSourceTiles = List<DashboardTile>.from(source.tiles)
    ..removeAt(fromTile);
  var destRowIndex = toRow;

  if (newSourceTiles.isEmpty) {
    rows.removeAt(fromRow);
    if (fromRow < destRowIndex) {
      destRowIndex--;
    }
  } else {
    rows[fromRow] = DashboardRow(
      heightUnits: source.heightUnits,
      minHeightPx: source.minHeightPx,
      tiles: newSourceTiles,
    );
  }

  destRowIndex = destRowIndex.clamp(0, rows.length);

  if (destRowIndex == rows.length) {
    if (minMoving > 6) return null;
    rows.add(
      DashboardRow(
        heightUnits: 1,
        tiles: [
          DashboardTile(
            widgetId: moving.widgetId,
            widthUnits: 6,
            spanRows: moving.spanRows,
            minHeightPx: moving.minHeightPx,
          ),
        ],
      ),
    );
    return v2.withRowsForScope(
      rows: rows,
      scope: scope,
      editAllScopes: editAllScopes,
    );
  }

  final target = rows[destRowIndex];
  final tgtTiles = List<DashboardTile>.from(target.tiles);
  final ins = insertTileIndex.clamp(0, tgtTiles.length);

  var width = moving.widthUnits;
  final sumExisting = tgtTiles.fold<int>(0, (a, t) => a + t.widthUnits);
  var room = 6 - sumExisting;
  if (room < minMoving) return null;
  if (width > room) width = room;
  width = width.clamp(minMoving, 6);

  final placed = DashboardTile(
    widgetId: moving.widgetId,
    widthUnits: width,
    spanRows: moving.spanRows,
    minHeightPx: moving.minHeightPx,
  );
  tgtTiles.insert(ins, placed);

  rows[destRowIndex] = DashboardRow(
    heightUnits: target.heightUnits,
    minHeightPx: target.minHeightPx,
    tiles: tgtTiles,
  );

  return v2.withRowsForScope(
    rows: rows,
    scope: scope,
    editAllScopes: editAllScopes,
  );
}

DashboardLayout resizeTileWidth(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  int rowIdx,
  int tileIdx,
  int newWidth, {
  MinWidthUnitsOf minWidthUnitsOf = defaultMinFlex,
}) {
  final v2 = doc.migrateToV2();
  final rows = DashboardLayout.cloneRows(v2.resolveRows(scope));
  if (rowIdx < 0 || rowIdx >= rows.length) return doc;
  final row = rows[rowIdx];
  final tiles = List<DashboardTile>.from(row.tiles);
  if (tileIdx < 0 || tileIdx >= tiles.length) return doc;

  if (tileIdx < tiles.length - 1) {
    final left = tiles[tileIdx];
    final right = tiles[tileIdx + 1];
    final leftMin = minWidthUnitsOf(left.widgetId).clamp(1, 6);
    final rightMin = minWidthUnitsOf(right.widgetId).clamp(1, 6);
    final pairSum = left.widthUnits + right.widthUnits;
    var wantLeft = newWidth.clamp(1, pairSum - 1);
    var wantRight = pairSum - wantLeft;
    if (wantLeft < leftMin) {
      wantLeft = leftMin;
      wantRight = pairSum - wantLeft;
    }
    if (wantRight < rightMin) {
      wantRight = rightMin;
      wantLeft = pairSum - wantRight;
    }
    if (wantLeft < leftMin || wantRight < rightMin) return doc;
    tiles[tileIdx] = left.copyWith(widthUnits: wantLeft);
    tiles[tileIdx + 1] = right.copyWith(widthUnits: wantRight);
  } else {
    final last = tiles[tileIdx];
    final others = tiles.sublist(0, tileIdx);
    final sumOthers =
        others.fold<int>(0, (a, t) => a + t.widthUnits);
    final lastMin = minWidthUnitsOf(last.widgetId).clamp(1, 6);
    final maxLast = 6 - sumOthers;
    if (maxLast < lastMin) return doc;
    final w = newWidth.clamp(lastMin, maxLast);
    tiles[tileIdx] = last.copyWith(widthUnits: w);
  }

  rows[rowIdx] = DashboardRow(
    heightUnits: row.heightUnits,
    minHeightPx: row.minHeightPx,
    tiles: tiles,
  );
  return v2.withRowsForScope(
    rows: rows,
    scope: scope,
    editAllScopes: editAllScopes,
  );
}

DashboardLayout resizeRowHeight(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  int rowIdx,
  int newHeightUnits, {
  MinHeightUnitsOf minHeightUnitsOf = defaultMinFlex,
}) {
  final v2 = doc.migrateToV2();
  final rows = DashboardLayout.cloneRows(v2.resolveRows(scope));
  if (rowIdx < 0 || rowIdx >= rows.length) return doc;
  final row = rows[rowIdx];
  var minRow = 1;
  for (final t in row.tiles) {
    final m = minHeightUnitsOf(t.widgetId).clamp(1, 6);
    if (m > minRow) minRow = m;
  }
  final h = newHeightUnits.clamp(minRow, 6);
  rows[rowIdx] = row.copyWith(heightUnits: h);
  return v2.withRowsForScope(
    rows: rows,
    scope: scope,
    editAllScopes: editAllScopes,
  );
}

DashboardLayout setBoardBreaks(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  List<int> breaks,
) {
  final v2 = doc.migrateToV2();
  final rc = v2.resolveRows(scope).length;
  final pres = v2
      .resolvePresentation(scope)
      .copyWith(boardBreaks: breaks)
      .normalized(rc);
  return v2.withPresentationForScope(
    presentation: pres,
    scope: scope,
    editAllScopes: editAllScopes,
    rowCountForNormalization: rc,
  );
}

DashboardLayout setOverflowMode(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  DashboardOverflowMode mode,
) {
  final v2 = doc.migrateToV2();
  final rc = v2.resolveRows(scope).length;
  final pres = v2.resolvePresentation(scope).copyWith(mode: mode).normalized(rc);
  return v2.withPresentationForScope(
    presentation: pres,
    scope: scope,
    editAllScopes: editAllScopes,
    rowCountForNormalization: rc,
  );
}

/// Inserts a break so a new board starts at row [afterRowIndex] + 1.
DashboardLayout addBoardAfter(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  int afterRowIndex,
) {
  final v2 = doc.migrateToV2();
  final rc = v2.resolveRows(scope).length;
  if (rc <= 1) return doc;
  final start = afterRowIndex + 1;
  if (start < 1 || start > rc - 1) return doc;
  final pres = v2.resolvePresentation(scope);
  if (pres.mode != DashboardOverflowMode.boards) return doc;
  final next = {...pres.boardBreaks, start}.toList()..sort();
  return setBoardBreaks(doc, scope, editAllScopes, next);
}

/// Merges the board containing [rowIndex] with the previous board.
DashboardLayout removeBoardContaining(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  int rowIndex,
) {
  final v2 = doc.migrateToV2();
  final rc = v2.resolveRows(scope).length;
  final pres = v2.resolvePresentation(scope);
  if (pres.mode != DashboardOverflowMode.boards || pres.boardBreaks.isEmpty) {
    return doc;
  }
  final slices = pres.normalized(rc).boardRowSlices(rc);
  var bi = 0;
  for (var i = 0; i < slices.length; i++) {
    if (slices[i].contains(rowIndex)) {
      bi = i;
      break;
    }
  }
  if (bi == 0) return doc;
  final br = List<int>.from(pres.boardBreaks)..sort();
  br.removeAt(bi - 1);
  return setBoardBreaks(doc, scope, editAllScopes, br);
}

/// Shifts width by ±1 flex through [resizeTileWidth] clamps.
DashboardLayout bumpTileWidthDelta(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  int rowIdx,
  int tileIdx,
  int deltaFlex, {
  MinWidthUnitsOf minWidthUnitsOf = defaultMinFlex,
}) {
  if (deltaFlex == 0) return doc;
  final rows =
      DashboardLayout.cloneRows(doc.migrateToV2().resolveRows(scope));
  if (rowIdx < 0 || rowIdx >= rows.length) return doc;
  final row = rows[rowIdx];
  if (tileIdx < 0 || tileIdx >= row.tiles.length) return doc;
  final tw = row.tiles[tileIdx].widthUnits + deltaFlex;
  return resizeTileWidth(
    doc,
    scope,
    editAllScopes,
    rowIdx,
    tileIdx,
    tw.clamp(1, 6),
    minWidthUnitsOf: minWidthUnitsOf,
  );
}

DashboardLayout bumpRowHeightDelta(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  int rowIdx,
  int deltaFlex, {
  MinHeightUnitsOf minHeightUnitsOf = defaultMinFlex,
}) {
  if (deltaFlex == 0) return doc;
  final rows =
      DashboardLayout.cloneRows(doc.migrateToV2().resolveRows(scope));
  if (rowIdx < 0 || rowIdx >= rows.length) return doc;
  final nh = rows[rowIdx].heightUnits + deltaFlex;
  return resizeRowHeight(
    doc,
    scope,
    editAllScopes,
    rowIdx,
    nh.clamp(1, 6),
    minHeightUnitsOf: minHeightUnitsOf,
  );
}

DashboardLayout detachTileIntoNewRow(
  DashboardLayout doc,
  DashboardScope scope,
  bool editAllScopes,
  int fromRow,
  int fromTile,
  int insertAtRow, {
  MinWidthUnitsOf minWidthUnitsOf = defaultMinFlex,
}) {
  final v2 = doc.migrateToV2();
  final rows = DashboardLayout.cloneRows(v2.resolveRows(scope));
  if (fromRow < 0 || fromRow >= rows.length) return doc;

  final source = rows[fromRow];
  if (fromTile < 0 || fromTile >= source.tiles.length) return doc;
  final moving = source.tiles[fromTile];

  final newSource = List<DashboardTile>.from(source.tiles)..removeAt(fromTile);
  var ins = insertAtRow;

  final emptied = newSource.isEmpty;

  if (emptied) {
    rows.removeAt(fromRow);
    if (fromRow < ins) {
      ins--;
    }
  } else {
    rows[fromRow] = DashboardRow(
      heightUnits: source.heightUnits,
      minHeightPx: source.minHeightPx,
      tiles: newSource,
    );
  }

  ins = ins.clamp(0, rows.length);

  final lone = DashboardTile(
    widgetId: moving.widgetId,
    widthUnits: 6,
    spanRows: moving.spanRows,
    minHeightPx: moving.minHeightPx,
  );
  rows.insert(
    ins,
    DashboardRow(
      heightUnits: 1,
      tiles: [lone],
    ),
  );

  return v2.withRowsForScope(
    rows: rows,
    scope: scope,
    editAllScopes: editAllScopes,
  );
}
