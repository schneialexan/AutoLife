import 'dart:math' as math;

import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dashboard_registry_provider.dart';
import 'dashboard_edit_chrome.dart';
import 'dashboard_grid_tile_row.dart';
import 'edit_mode/reorderable_dashboard.dart';

export 'dashboard_edit_chrome.dart';

const double kDashboardScrollUnitHeight = 96;
const double kDashboardMinTileHeight = 96;

class DashboardHost extends ConsumerStatefulWidget {
  const DashboardHost({
    super.key,
    required this.document,
    required this.scope,
    this.editModeOptions,
    this.onAutoFitUsesScrollFallback,
  });

  final DashboardLayout document;
  final DashboardScope scope;
  final DashboardEditChrome? editModeOptions;
  final ValueChanged<bool>? onAutoFitUsesScrollFallback;

  @override
  ConsumerState<DashboardHost> createState() => _DashboardHostState();
}

class _DashboardHostState extends ConsumerState<DashboardHost> {
  final PageController _boardsPage = PageController();

  @override
  void dispose() {
    _boardsPage.dispose();
    super.dispose();
  }

  bool _rowsCanFlex(List<DashboardRow> rows, double viewportH) {
    if (!viewportH.isFinite || viewportH <= 0) return false;
    final totalUnits = rows.fold<int>(0, (a, r) => a + r.heightUnits);
    if (totalUnits == 0) return false;
    final perUnit = viewportH / totalUnits;
    return rows.every((r) {
      final px = r.heightUnits * perUnit;
      final minPx = math.max(
        kDashboardMinTileHeight,
        r.rowMinHeightPx > 0 ? r.rowMinHeightPx.toDouble() : 0,
      );
      return px >= minPx;
    });
  }

  @override
  Widget build(BuildContext context) {
    final registry = ref.watch(dashboardWidgetRegistryProvider);
    final pres = widget.document.resolvePresentation(widget.scope);
    final rows = widget.document.resolveRows(widget.scope);
    if (rows.isEmpty) {
      return const Center(child: Text('No dashboard rows'));
    }

    final chrome = widget.editModeOptions;
    final editing = chrome?.isEditing ?? false;
    final deepEdit = editing && chrome?.onRowReorder != null;

    return LayoutBuilder(
      builder: (ctx, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        if (deepEdit) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (pres.mode == DashboardOverflowMode.autoFit) {
              widget.onAutoFitUsesScrollFallback?.call(!_rowsCanFlex(rows, h));
            } else {
              widget.onAutoFitUsesScrollFallback?.call(false);
            }
          });
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Editing · display: ${pres.mode.name}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                ReorderableDashboard(
                  rows: rows,
                  registry: registry,
                  chrome: chrome!,
                  viewportWidth: w.isFinite ? w : MediaQuery.of(context).size.width,
                  viewportHeight:
                      h.isFinite ? h : MediaQuery.of(context).size.height,
                ),
              ],
            ),
          );
        }

        switch (pres.mode) {
          case DashboardOverflowMode.scrollVertical:
            return _scrollVerticalColumn(context, registry, rows, chrome);
          case DashboardOverflowMode.scrollSnap:
            return _snapPages(context, registry, rows, chrome, h);
          case DashboardOverflowMode.boards:
            return _horizontalBoards(context, registry, rows, pres, chrome);
          case DashboardOverflowMode.autoFit:
            return _autoFitView(context, registry, rows, chrome, w, h);
        }
      },
    );
  }

  Widget _scrollVerticalColumn(
    BuildContext context,
    DashboardWidgetRegistry registry,
    List<DashboardRow> rows,
    DashboardEditChrome? chrome,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++)
            SizedBox(
              height: math.max(
                kDashboardScrollUnitHeight,
                rows[i].heightUnits * kDashboardScrollUnitHeight * 0.72,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DashboardGridTileRow(
                  row: rows[i],
                  rowIndex: i,
                  registry: registry,
                  editChrome: chrome,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _snapPages(
    BuildContext context,
    DashboardWidgetRegistry registry,
    List<DashboardRow> rows,
    DashboardEditChrome? chrome,
    double viewportHeight,
  ) {
    final chunks = _chunkRows(rows, maxUnits: 6);
    if (chunks.isEmpty) return const SizedBox.shrink();
    final h = viewportHeight.isFinite && viewportHeight > 0
        ? viewportHeight
        : 560.0;
    return SizedBox(
      height: h,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: chunks.length,
        physics: const PageScrollPhysics(),
        itemBuilder: (_, pageIdx) {
          final slice = chunks[pageIdx];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < slice.length; i++)
                Expanded(
                  flex: slice[i].heightUnits,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DashboardGridTileRow(
                      row: slice[i],
                      rowIndex: rows.indexOf(slice[i]),
                      registry: registry,
                      editChrome: chrome,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _horizontalBoards(
    BuildContext context,
    DashboardWidgetRegistry registry,
    List<DashboardRow> rows,
    DashboardPresentation pres,
    DashboardEditChrome? chrome,
  ) {
    final slices = pres.normalized(rows.length).boardRowSlices(rows.length);
    return PageView.builder(
      controller: _boardsPage,
      physics: const PageScrollPhysics(),
      itemCount: slices.length,
      itemBuilder: (_, bi) {
        final idxs = slices[bi];
        final sub = idxs.map((ix) => rows[ix]).toList(growable: false);
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: LayoutBuilder(
            builder: (_, bc) {
              final h = bc.maxHeight;
              return _flexColumnForRows(
                context,
                registry,
                sub,
                chrome,
                rows,
                h,
              );
            },
          ),
        );
      },
    );
  }

  Widget _flexColumnForRows(
    BuildContext context,
    DashboardWidgetRegistry registry,
    List<DashboardRow> subset,
    DashboardEditChrome? chrome,
    List<DashboardRow> fullRows,
    double totalH,
  ) {
    if (!totalH.isFinite || totalH <= 0) {
      return _scrollVerticalColumn(context, registry, subset, chrome);
    }
    final totalUnits = subset.fold<int>(0, (a, r) => a + r.heightUnits);
    if (totalUnits == 0) {
      return _scrollVerticalColumn(context, registry, subset, chrome);
    }
    final perUnit = totalH / totalUnits;
    final canFlex = subset.every((r) {
      final px = r.heightUnits * perUnit;
      final minPx = math.max(
        kDashboardMinTileHeight,
        r.rowMinHeightPx > 0 ? r.rowMinHeightPx.toDouble() : 0,
      );
      return px >= minPx;
    });

    if (!canFlex) {
      return _scrollVerticalColumn(context, registry, subset, chrome);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < subset.length; i++)
          Expanded(
            flex: subset[i].heightUnits,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DashboardGridTileRow(
                row: subset[i],
                rowIndex: fullRows.indexOf(subset[i]),
                registry: registry,
                editChrome: chrome,
              ),
            ),
          ),
      ],
    );
  }

  Widget _autoFitView(
    BuildContext context,
    DashboardWidgetRegistry registry,
    List<DashboardRow> rows,
    DashboardEditChrome? chrome,
    double viewportW,
    double viewportH,
  ) {
    if (!_rowsCanFlex(rows, viewportH)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAutoFitUsesScrollFallback?.call(true);
      });
      return _scrollFallback(context, registry, rows, chrome);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAutoFitUsesScrollFallback?.call(false);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++)
          Expanded(
            flex: rows[i].heightUnits,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DashboardGridTileRow(
                row: rows[i],
                rowIndex: i,
                registry: registry,
                editChrome: chrome,
              ),
            ),
          ),
      ],
    );
  }

  Widget _scrollFallback(
    BuildContext context,
    DashboardWidgetRegistry registry,
    List<DashboardRow> rows,
    DashboardEditChrome? chrome,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++)
            SizedBox(
              height: math.max(120, rows[i].heightUnits * 72),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DashboardGridTileRow(
                  row: rows[i],
                  rowIndex: i,
                  registry: registry,
                  editChrome: chrome,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

List<List<DashboardRow>> _chunkRows(List<DashboardRow> rows, {required int maxUnits}) {
  final out = <List<DashboardRow>>[];
  var buf = <DashboardRow>[];
  var acc = 0;
  for (final r in rows) {
    if (acc > 0 && acc + r.heightUnits > maxUnits) {
      out.add(buf);
      buf = [];
      acc = 0;
    }
    buf.add(r);
    acc += r.heightUnits;
  }
  if (buf.isNotEmpty) {
    out.add(buf);
  }
  return out;
}
