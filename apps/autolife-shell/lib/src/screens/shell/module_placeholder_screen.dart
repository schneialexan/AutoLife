import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';

/// Module shell placeholder until phases 3.2–3.4 ship full UIs (phase 3.1).
class ModulePlaceholderScreen extends StatelessWidget {
  const ModulePlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AutoLifeSpacing.md),
      child: Center(
        child: AutoLifeSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(AutoLifeSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AutoLifeSpacing.sm),
                Text(
                  'Module UI lands in a later phase — navigation shell only.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
