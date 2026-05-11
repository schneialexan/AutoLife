import 'package:flutter/material.dart';

import 'package:autolife_ui/src/tokens/spacing.dart';

/// App bar styled with AutoLife spacing defaults.
class AutoLifeAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Toolbar with optional [actions] and transparent elevation.
  const AutoLifeAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      scrolledUnderElevation: 0,
      titleSpacing: AutoLifeSpacing.md,
    );
  }
}
