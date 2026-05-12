/// Edit-mode gestures wired from reorder + resize layers.
class DashboardEditChrome {
  const DashboardEditChrome({
    required this.isEditing,
    this.onTileDelete,
    /// +1 = steal unit from tile on the right, -1 = give unit back when possible.
    this.onTileResizeWidthDelta,
    /// +1 = taller band, -1 = shorter band (still clamped to min row height).
    this.onRowResizeHeightDelta,
    this.onRowReorder,
    this.onTileReorderInRow,
    /// Move tile [`from`*] onto row/toTile insert index.
    this.onTileMoveCrossRow,
    /// Drag-drop onto lane between rows inserts a lone row with that widget.
    this.onDetachTileIntoNewRowAt,
    this.onOpenTileResizePopover,
    this.onOpenRowResizePopover,
  });

  final bool isEditing;
  final void Function(int rowIndex, int tileIndex)? onTileDelete;
  final void Function(int rowIndex, int tileIndex, int deltaFlex)?
      onTileResizeWidthDelta;
  final void Function(int rowIndex, int deltaFlex)? onRowResizeHeightDelta;
  final void Function(int oldRowIndex, int newRowIndex)? onRowReorder;
  final void Function(int rowIndex, int oldTileIndex, int newTileIndex)?
      onTileReorderInRow;
  final void Function(int fromRow, int fromTile, int toRow, int toTileInsert)?
      onTileMoveCrossRow;
  final void Function(int insertRowIndex, int fromRow, int fromTile)?
      onDetachTileIntoNewRowAt;
  final void Function(int rowIndex, int tileIndex)? onOpenTileResizePopover;
  final void Function(int rowIndex)? onOpenRowResizePopover;
}
