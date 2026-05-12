import 'package:flutter/material.dart';

/// Drag handle on a dashboard row for reordering (phase 3.1.5).
class RowReorderHandle extends StatelessWidget {
  const RowReorderHandle({
    super.key,
    this.onReorder,
  });

  final void Function()? onReorder;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Reorder row',
      button: true,
      child: IconButton(
        tooltip: 'Drag to reorder row',
        icon: Icon(
          Icons.drag_handle,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: onReorder,
      ),
    );
  }
}
