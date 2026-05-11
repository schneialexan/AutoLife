import 'package:flutter/material.dart';

import 'package:autolife_ui/src/tokens/spacing.dart';

/// Omnibar-style compact search field for shell chrome.
///
/// Omnibar field used directly or via the [AutoOmnibar] alias.
class AutoLifeOmnibar extends StatelessWidget {
  /// Debounced-style submission fires when the user presses "done" on the keyboard.
  const AutoLifeOmnibar({
    super.key,
    this.controller,
    this.hintText = 'Search calendar, tasks, assets…',
    required this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String> onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AutoLifeSpacing.sm,
          ),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

/// Type alias matching shell naming (`AutoOmnibar`).
typedef AutoOmnibar = AutoLifeOmnibar;
