import 'package:flutter/material.dart';

/// Drag-handle resize UX between dashboard rows/tiles (phase 3.1.5).
/// Wire into [DashboardHost] when interactive resize is implemented.
class TileResizeHandles extends StatelessWidget {
  const TileResizeHandles({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
