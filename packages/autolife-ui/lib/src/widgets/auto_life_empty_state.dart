import 'package:flutter/material.dart';

import 'package:autolife_ui/src/tokens/spacing.dart';

/// Empty content placeholder with optional primary action.
class AutoLifeEmptyState extends StatelessWidget {
  /// Centered icon, title, body, and optional CTA.
  const AutoLifeEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AutoLifeSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: scheme.onSurfaceVariant),
              const SizedBox(height: AutoLifeSpacing.md),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(color: scheme.onSurface),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AutoLifeSpacing.xs),
                Text(
                  message!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AutoLifeSpacing.md),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
