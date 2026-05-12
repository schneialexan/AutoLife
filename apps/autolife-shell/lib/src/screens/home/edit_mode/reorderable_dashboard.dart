import 'dart:math' as math;

import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';

import '../dashboard_edit_chrome.dart';
import '../dashboard_grid_tile_row.dart';
import 'row_reorder_handle.dart';

/// Cross-row drag metadata.
class DashboardTileDragData {
  const DashboardTileDragData({
    required this.fromRowIndex,
    required this.fromTileIndex,
  });

  final int fromRowIndex;
  final int fromTileIndex;
}

const double kDashboardReorderMinRowHeight = 112;

/// Edit-mode: reorderable rows / tiles + drop targets + thin resize gutters.
class ReorderableDashboard extends StatelessWidget {
  const ReorderableDashboard({
    super.key,
    required this.rows,
    required this.registry,
    required this.chrome,
    required this.viewportWidth,
    required this.viewportHeight,
  });

  final List<DashboardRow> rows;
  final DashboardWidgetRegistry registry;
  final DashboardEditChrome chrome;
  final double viewportWidth;
  final double viewportHeight;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final totalU = math.max(
      1,
      rows.fold<int>(0, (a, r) => a + r.heightUnits),
    );

    if (!chrome.isEditing || chrome.onRowReorder == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++)
            _ManualRowBand(
              rows: rows,
              rowIndex: i,
              totalUnits: totalU,
              viewportWidth: viewportWidth,
              viewportHeight: viewportHeight,
              registry: registry,
              chrome: chrome,
            ),
        ],
      );
    }

    return ReorderableListView.builder(
      primary: false,
      buildDefaultDragHandles: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      itemBuilder: (ctx, i) => KeyedSubtree(
        key: ValueKey<String>('dash_r_${i}_${rows[i].tiles.length}'),
        child: Material(
          type: MaterialType.transparency,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReorderableDragStartListener(
                  index: i,
                  child: SizedBox(
                    width: 44,
                    child: RowReorderHandle(onReorder: () {}),
                  ),
                ),
                Expanded(
                  child: _ManualRowBand(
                    rows: rows,
                    rowIndex: i,
                    totalUnits: totalU,
                    viewportWidth: viewportWidth.isFinite
                        ? viewportWidth - 44
                        : viewportWidth,
                    viewportHeight: viewportHeight,
                    registry: registry,
                    chrome: chrome,
                    wrapTiles: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onReorder: (oldIndex, newIndex) {
        var n = newIndex;
        if (oldIndex < n) {
          n--;
        }
        final rowCount = rows.length;
        chrome.onRowReorder?.call(oldIndex.clamp(0, rowCount - 1), n.clamp(0, rowCount - 1));
      },
    );
  }
}

/// One row strip (tiles + optional row-height gutter below).
class _ManualRowBand extends StatelessWidget {
  const _ManualRowBand({
    required this.rows,
    required this.rowIndex,
    required this.totalUnits,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.registry,
    required this.chrome,
    this.wrapTiles = false,
  });

  final List<DashboardRow> rows;
  final int rowIndex;
  final int totalUnits;
  final double viewportWidth;
  final double viewportHeight;
  final DashboardWidgetRegistry registry;
  final DashboardEditChrome chrome;
  final bool wrapTiles;

  @override
  Widget build(BuildContext context) {
    final row = rows[rowIndex];
    final frac = row.heightUnits / totalUnits;
    final bandH = math
        .max(kDashboardReorderMinRowHeight, viewportHeight * frac)
        .clamp(kDashboardReorderMinRowHeight, 560)
        .toDouble();

    final w = viewportWidth.isFinite ? viewportWidth : MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: bandH,
          width: viewportWidth.isFinite ? viewportWidth : double.infinity,
          child:
              _TileStrip(
                rows: rows,
                rowIndex: rowIndex,
                registry: registry,
                chrome: chrome,
                viewportWidth: w,
                wrapTilesHorizontally:
                    chrome.isEditing && chrome.onTileReorderInRow != null && wrapTiles,
              ),
        ),
        if (chrome.onRowResizeHeightDelta != null)
          _RowHeightResizeStrip(rowIndex: rowIndex, chrome: chrome),
        if (chrome.onDetachTileIntoNewRowAt != null && rowIndex < rows.length - 1)
          _InsertRowLane(atIndex: rowIndex + 1, chrome: chrome),
      ],
    );
  }
}

class _TileStrip extends StatelessWidget {
  const _TileStrip({
    required this.rows,
    required this.rowIndex,
    required this.registry,
    required this.chrome,
    required this.viewportWidth,
    required this.wrapTilesHorizontally,
  });

  final List<DashboardRow> rows;
  final int rowIndex;
  final DashboardWidgetRegistry registry;
  final DashboardEditChrome chrome;
  final double viewportWidth;
  final bool wrapTilesHorizontally;

  DashboardRow get row => rows[rowIndex];

  @override
  Widget build(BuildContext context) {
    if (!wrapTilesHorizontally ||
        chrome.onTileReorderInRow == null ||
        row.tiles.length <= 1) {
      return DashboardGridTileRow(
        row: row,
        rowIndex: rowIndex,
        registry: registry,
        editChrome: chrome,
        tileDecorator:
            chrome.isEditing && chrome.onTileMoveCrossRow != null
                ? _crossRowDecorator(viewportWidth)
                : chrome.onTileResizeWidthDelta != null
                    ? _resizeThumbDecorator(viewportWidth)
                    : null,
      );
    }

    final cell = viewportWidth / 6.0;
    final tiles = row.tiles;

    return ReorderableListView.builder(
      primary: false,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      buildDefaultDragHandles: false,
      physics: const ClampingScrollPhysics(),
      itemCount: tiles.length,
      itemBuilder: (ctx, ti) {
        final tw = tiles[ti].widthUnits.clamp(1, 6).toDouble() * math.max(cell, 1);
        final inner = SizedBox(
          width: tw,
          child: DashboardGridTileRow(
            row: DashboardRow(
              heightUnits: row.heightUnits,
              minHeightPx: row.minHeightPx,
              tiles: [tiles[ti]],
            ),
            rowIndex: rowIndex,
            registry: registry,
            editChrome: chrome,
            tileDecorator: _combinedDecorator(cell),
          ),
        );
        return KeyedSubtree(
          key: ValueKey<String>(
            '${rowIndex}_${tiles[ti].widgetId}_u${tiles[ti].widthUnits}_$ti',
          ),
          child: ReorderableDragStartListener(index: ti, child: inner),
        );
      },
      onReorder: (o, n) {
        var ni = n;
        if (o < ni) {
          ni--;
        }
        chrome.onTileReorderInRow?.call(rowIndex, o, ni);
      },
    );
  }

  Widget Function(BuildContext ctx, int tileIndex, Widget child) _combinedDecorator(double cell) {
    return (ctx, ti, child) =>
        chrome.onTileMoveCrossRow != null
            ? _CrossRowDragTile(
                rowIndex: rowIndex,
                tileIndex: ti,
                cellWidthApprox: cell,
                chrome: chrome,
                child: _TileWidthResizeThumb(
                  rowIndex: rowIndex,
                  tileIndex: ti,
                  cellPixels: cell,
                  chrome: chrome,
                  hasRightNeighbor: ti < rows[rowIndex].tiles.length - 1,
                  child: child,
                ),
              )
            : _TileWidthResizeThumb(
                rowIndex: rowIndex,
                tileIndex: ti,
                cellPixels: cell,
                chrome: chrome,
                hasRightNeighbor: ti < rows[rowIndex].tiles.length - 1 ||
                    rows[rowIndex].tiles.fold<int>(
                          0,
                          (s, x) => s + x.widthUnits,
                        ) <
                        6,
                child: child,
              );
  }

  Widget Function(BuildContext ctx, int tileIndex, Widget child) _crossRowDecorator(double cell) {
    return (ctx, ti, child) => _CrossRowDragTile(
      rowIndex: rowIndex,
      tileIndex: ti,
      cellWidthApprox: cell,
      chrome: chrome,
      child: _TileWidthResizeThumb(
        rowIndex: rowIndex,
        tileIndex: ti,
        cellPixels: cell,
        chrome: chrome,
        hasRightNeighbor:
            ti < row.tiles.length - 1 ||
            row.tiles.fold<int>(0, (s, x) => s + x.widthUnits) < 6,
        child: child,
      ),
    );
  }

  Widget Function(BuildContext ctx, int tileIndex, Widget child)? _resizeThumbDecorator(
    double cell,
  ) {
    return (ctx, ti, child) => _TileWidthResizeThumb(
      rowIndex: rowIndex,
      tileIndex: ti,
      cellPixels: cell,
      chrome: chrome,
      hasRightNeighbor:
          ti < row.tiles.length - 1 ||
          row.tiles.fold<int>(0, (s, x) => s + x.widthUnits) < 6,
      child: child,
    );
  }
}

class _CrossRowDragTile extends StatelessWidget {
  const _CrossRowDragTile({
    required this.rowIndex,
    required this.tileIndex,
    required this.cellWidthApprox,
    required this.child,
    required this.chrome,
  });

  final int rowIndex;
  final int tileIndex;
  final double cellWidthApprox;
  final Widget child;
  final DashboardEditChrome chrome;

  @override
  Widget build(BuildContext context) {
    if (chrome.onTileMoveCrossRow == null) {
      return child;
    }
    Widget inner = DragTarget<DashboardTileDragData>(
      onWillAcceptWithDetails: (det) =>
          det.data.fromRowIndex != rowIndex ||
          det.data.fromTileIndex != tileIndex,
      onAcceptWithDetails: (det) => chrome.onTileMoveCrossRow?.call(
            det.data.fromRowIndex,
            det.data.fromTileIndex,
            rowIndex,
            tileIndex,
          ),
      builder:
          (ctx, cand, _) => AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cand.isNotEmpty ? Theme.of(ctx).colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: child,
          ),
    );

    inner = LongPressDraggable<DashboardTileDragData>(
      data: DashboardTileDragData(fromRowIndex: rowIndex, fromTileIndex: tileIndex),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: SizedBox(
        width: math.max(cellWidthApprox * 2, 80),
        height: 56,
        child: Material(
          elevation: 6,
          child: const Center(child: Text('Moving…')),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: inner),
      child: inner,
    );
    return inner;
  }
}

class _TileWidthResizeThumb extends StatefulWidget {
  const _TileWidthResizeThumb({
    required this.rowIndex,
    required this.tileIndex,
    required this.cellPixels,
    required this.chrome,
    required this.hasRightNeighbor,
    required this.child,
  });

  final int rowIndex;
  final int tileIndex;
  final double cellPixels;
  final DashboardEditChrome chrome;
  final bool hasRightNeighbor;
  final Widget child;

  @override
  State<_TileWidthResizeThumb> createState() => _TileWidthResizeThumbState();
}

class _TileWidthResizeThumbState extends State<_TileWidthResizeThumb> {
  double _accum = 0;

  @override
  Widget build(BuildContext context) {
    if (!widget.hasRightNeighbor || widget.chrome.onTileResizeWidthDelta == null) {
      return widget.child;
    }
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: 14,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) {
              _accum += d.delta.dx;
              final thresh = widget.cellPixels * 0.42;
              if (_accum.abs() < thresh) {
                return;
              }
              final step = _accum > 0 ? 1 : -1;
              _accum = 0;
              widget.chrome.onTileResizeWidthDelta!(
                widget.rowIndex,
                widget.tileIndex,
                step,
              );
            },
            onHorizontalDragEnd: (_) => _accum = 0,
            child:
                Tooltip(
                  message: 'Drag to resize tile width',
                  child: Container(color: Colors.white24),
                ),
          ),
        ),
      ],
    );
  }
}

class _RowHeightResizeStrip extends StatefulWidget {
  const _RowHeightResizeStrip({required this.rowIndex, required this.chrome});

  final int rowIndex;
  final DashboardEditChrome chrome;

  @override
  State<_RowHeightResizeStrip> createState() => _RowHeightResizeStripState();
}

class _RowHeightResizeStripState extends State<_RowHeightResizeStrip> {
  double _accum = 0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (d) {
          _accum += d.delta.dy;
          if (_accum.abs() < 28) {
            return;
          }
          final step = _accum > 0 ? -1 : 1;
          _accum = 0;
          widget.chrome.onRowResizeHeightDelta?.call(widget.rowIndex, step);
        },
        onVerticalDragEnd: (_) => _accum = 0,
        child: Container(
          height: 10,
          color: Colors.white12,
          margin: const EdgeInsets.only(bottom: 4),
        ),
      ),
    );
  }
}

class _InsertRowLane extends StatelessWidget {
  const _InsertRowLane({required this.atIndex, required this.chrome});

  final int atIndex;
  final DashboardEditChrome chrome;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: DragTarget<DashboardTileDragData>(
        onWillAcceptWithDetails:
            (_) => chrome.onDetachTileIntoNewRowAt != null,
        onAcceptWithDetails:
            (det) =>
                chrome.onDetachTileIntoNewRowAt?.call(
                  atIndex,
                  det.data.fromRowIndex,
                  det.data.fromTileIndex,
                ),
        builder:
            (ctx, c, _) => Container(
              color:
                  c.isNotEmpty
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Colors.transparent,
            ),
      ),
    );
  }
}
