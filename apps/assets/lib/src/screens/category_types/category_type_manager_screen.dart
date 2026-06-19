import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category_type.dart';
import '../../providers/category_type_providers.dart';
import '../../widgets/category_icon.dart';
import 'category_type_form_dialog.dart';

class CategoryTypeManagerScreen extends ConsumerWidget {
  const CategoryTypeManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final types = ref.watch(categoryTypesProvider);
    final usage = ref.watch(typeUsageProvider);
    final atLimit = types.length >= CategoryType.maxTypes;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Define what you track and what kind of value it holds.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${types.length} of ${CategoryType.maxTypes} types used',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: atLimit
                          ? null
                          : () => showCategoryTypeForm(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add type'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: types.length / CategoryType.maxTypes,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: types.isEmpty
                ? Center(
                    child: Text(
                      'No category types yet.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    itemCount: types.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final type = types[index];
                      return _TypeRow(
                        type: type,
                        usageCount: usage[type.id] ?? 0,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TypeRow extends ConsumerWidget {
  const _TypeRow({required this.type, required this.usageCount});

  final CategoryType type;
  final int usageCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final usageLine = usageCount == 0
        ? 'Not used yet'
        : 'Used on $usageCount asset${usageCount == 1 ? '' : 's'}';
    final optionsLine = type.valueKind.requiresOptions
        ? ' \u00b7 ${type.options?.length ?? 0} options'
        : '';

    return ListTile(
      leading: CategoryTile(type: type),
      title: Row(
        children: [
          Flexible(child: Text(type.name)),
          const SizedBox(width: 8),
          _KindPill(label: type.valueKind.label),
          if (type.isArchived) ...[
            const SizedBox(width: 6),
            _KindPill(label: 'Archived'),
          ],
        ],
      ),
      subtitle: Text(
        '$usageLine$optionsLine',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: PopupMenuButton<String>(
        tooltip: 'More actions for ${type.name}',
        onSelected: (value) => _onAction(context, ref, value),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'rename', child: Text('Rename / edit')),
          PopupMenuItem(
            value: 'archive',
            child: Text(type.isArchived ? 'Unarchive' : 'Archive'),
          ),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final notifier = ref.read(categoryTypesProvider.notifier);
    switch (action) {
      case 'rename':
        await showCategoryTypeForm(context, existing: type);
      case 'archive':
        await notifier.archive(type, archived: !type.isArchived);
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete ${type.name}?'),
            content: const Text(
              'This removes the type from the catalog. Existing asset values '
              'for this type will no longer be shown.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed ?? false) {
          await notifier.delete(type.id);
        }
    }
  }
}

class _KindPill extends StatelessWidget {
  const _KindPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: theme.textTheme.labelSmall),
    );
  }
}
