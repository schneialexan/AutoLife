import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';

import 'dashboard_edit_chrome.dart';

/// One row band: flex [Row] of tiles for the dashboard grid.
class DashboardGridTileRow extends StatelessWidget {
  const DashboardGridTileRow({
    super.key,
    required this.row,
    required this.rowIndex,
    required this.registry,
    this.editChrome,
    this.tileDecorator,
  });

  final DashboardRow row;
  final int rowIndex;
  final DashboardWidgetRegistry registry;
  final DashboardEditChrome? editChrome;

  /// Wraps each tile (e.g. drag targets, draggable) while preserving flex layout.
  final Widget Function(BuildContext context, int tileIndex, Widget tileChild)?
      tileDecorator;

  @override
  Widget build(BuildContext context) {
    if (row.tiles.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var j = 0; j < row.tiles.length; j++)
          Expanded(
            flex: row.tiles[j].widthUnits,
            child: _buildTile(context, j),
          ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, int tileIndex) {
    final tile = row.tiles[tileIndex];
    final spec = registry.lookup(tile.widgetId);
    final slot = DashboardSlot(
      widgetId: tile.widgetId,
      requestedSize: DashboardSize.m,
    );
    Widget child = spec == null
        ? _MissingTile(widgetId: tile.widgetId)
        : spec.build(context, slot);

    if (editChrome?.isEditing ?? false) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: child),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: 'Remove widget',
                icon: const Icon(Icons.close, size: 20),
                onPressed: () =>
                    editChrome?.onTileDelete?.call(rowIndex, tileIndex),
              ),
            ),
            if (editChrome?.onOpenTileResizePopover != null)
              Positioned(
                bottom: 4,
                left: 4,
                child: IconButton(
                  tooltip: 'Resize tile width',
                  icon: const Icon(Icons.aspect_ratio, size: 20),
                  onPressed: () =>
                      editChrome!.onOpenTileResizePopover!(
                        rowIndex,
                        tileIndex,
                      ),
                ),
              ),
            if (editChrome?.onOpenRowResizePopover != null)
              Positioned(
                bottom: 4,
                left: 44,
                child: IconButton(
                  tooltip: 'Resize row height',
                  icon: const Icon(Icons.vertical_align_center, size: 20),
                  onPressed: () =>
                      editChrome!.onOpenRowResizePopover!(rowIndex),
                ),
              ),
          ],
        ),
      );
    }

    final wrapped = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
    if (tileDecorator != null) {
      return tileDecorator!(context, tileIndex, wrapped);
    }
    return wrapped;
  }
}

class _MissingTile extends StatelessWidget {
  const _MissingTile({required this.widgetId});

  final String widgetId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Unknown: $widgetId',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ),
      ),
    );
  }
}
