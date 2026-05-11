/// AutoLife design system (Phase 1.3+).
library;

import 'package:flutter/widgets.dart';

/// Minimal widget so the shell can depend on the package before design tokens exist.
class AutolifePlaceholder extends StatelessWidget {
  const AutolifePlaceholder({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
