import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category_type.dart';
import '../../providers/category_type_providers.dart';
import '../../widgets/category_icon.dart';
import '../category_types/category_type_form_dialog.dart';

/// Opens the thumb-anchored sheet to add a category field to an asset. Returns
/// the chosen (or newly created) [CategoryType], or null if dismissed.
Future<CategoryType?> showAddCategorySheet(
  BuildContext context, {
  required Set<String> excludeIds,
}) {
  return showModalBottomSheet<CategoryType>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _AddCategorySheet(excludeIds: excludeIds),
  );
}

class _AddCategorySheet extends ConsumerStatefulWidget {
  const _AddCategorySheet({required this.excludeIds});

  final Set<String> excludeIds;

  @override
  ConsumerState<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<_AddCategorySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = ref
        .watch(activeCategoryTypesProvider)
        .where((t) => !widget.excludeIds.contains(t.id))
        .where(
          (t) => t.name.toLowerCase().contains(_query.trim().toLowerCase()),
        )
        .toList();

    return FractionallySizedBox(
      heightFactor: 0.82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add a category', style: theme.textTheme.titleLarge),
                const SizedBox(height: 10),
                SearchBar(
                  leading: const Icon(Icons.search),
                  hintText: 'Search types',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: available.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No more types to add.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: available.length,
                    itemBuilder: (context, index) {
                      final type = available[index];
                      return ListTile(
                        leading: CategoryTile(type: type),
                        title: Text(type.name),
                        subtitle: Text(type.valueKind.label),
                        trailing: const Icon(Icons.add),
                        onTap: () => Navigator.of(context).pop(type),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final created = await showCategoryTypeForm(context);
                  if (created != null && context.mounted) {
                    Navigator.of(context).pop(created);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Create new type'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
