import 'package:flutter/material.dart';

/// Pre-save conflict strip with alternate slot suggestions.
class ConflictBar extends StatelessWidget {
  const ConflictBar({
    super.key,
    required this.title,
    required this.alternatives,
    this.onPick,
  });

  final String title;
  final List<DateTime> alternatives;
  final void Function(DateTime slot)? onPick;

  @override
  Widget build(BuildContext context) {
    if (alternatives.isEmpty) return const SizedBox.shrink();
    return Material(
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: alternatives
                  .map(
                    (t) => ActionChip(
                      label: Text(t.toLocal().toString()),
                      onPressed: onPick == null ? null : () => onPick!(t),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
