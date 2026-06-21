import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/asset.dart';
import '../../models/category_type.dart';
import '../../providers/asset_providers.dart';
import '../../providers/category_type_providers.dart';
import '../../widgets/category_icon.dart';
import '../asset_detail_screen.dart';
import '../asset_form/asset_form_screen.dart';
import '../settings/settings_screen.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  String _query = '';

  /// typeId -> required value (single value filter per type).
  final Map<String, String> _filters = <String, String>{};

  bool _matchesQuery(Asset asset) {
    if (_query.trim().isEmpty) {
      return true;
    }
    final q = _query.toLowerCase();
    final haystack = <String>[
      asset.displayLabel,
      if (asset.name != null) asset.name!,
      if (asset.price != null) asset.price!.format(),
      if (asset.purchaseDate != null)
        DateFormat('d MMM y').format(asset.purchaseDate!),
      for (final v in asset.propertyValues.values) v.displayString(),
    ];
    return haystack.any((s) => s.toLowerCase().contains(q));
  }

  bool _matchesFilters(Asset asset) {
    for (final entry in _filters.entries) {
      final value = asset.propertyValues[entry.key];
      if (value == null ||
          value.displayString().toLowerCase() != entry.value.toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(assetsProvider);
    final hasAnyAssets = assets.isNotEmpty;
    final visible = assets.where(_matchesQuery).where(_matchesFilters).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoAssets'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add asset',
        onPressed: _openNewAsset,
        child: const Icon(Icons.add),
      ),
      body: hasAnyAssets
          ? _buildContent(context, visible)
          : const _EmptyState(),
    );
  }

  Widget _buildContent(BuildContext context, List<Asset> visible) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: SearchBar(
            leading: const Icon(Icons.search),
            hintText: 'Search assets',
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        _FilterRow(
          filters: _filters,
          onAddFilter: _openFilterSheet,
          onRemove: (id) => setState(() => _filters.remove(id)),
          onClearAll: () => setState(_filters.clear),
        ),
        Expanded(
          child: visible.isEmpty
              ? const _ZeroResults()
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 96),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    return _AssetCard(
                      asset: visible[index],
                      onTap: () => _openDetail(visible[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _openNewAsset() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AssetFormScreen()));
  }

  void _openDetail(Asset asset) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssetDetailScreen(assetId: asset.id),
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final types = ref.read(activeCategoryTypesProvider);
    final assets = ref.read(assetsProvider);
    final selectedType = await showModalBottomSheet<CategoryType>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final candidates = types
            .where((t) => !_filters.containsKey(t.id))
            .where(
              (t) =>
                  assets.any((a) => !(a.propertyValues[t.id]?.isEmpty ?? true)),
            )
            .toList();
        if (candidates.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No values to filter by yet.'),
          );
        }
        return ListView(
          shrinkWrap: true,
          children: [
            for (final type in candidates)
              ListTile(
                leading: CategoryTile(type: type, size: 32),
                title: Text(type.name),
                onTap: () => Navigator.of(context).pop(type),
              ),
          ],
        );
      },
    );
    if (selectedType == null || !mounted) {
      return;
    }
    final values = <String>{
      for (final asset in assets)
        if (!(asset.propertyValues[selectedType.id]?.isEmpty ?? true))
          asset.propertyValues[selectedType.id]!.displayString(),
    }.toList()..sort();
    if (!mounted) {
      return;
    }
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            for (final v in values)
              ListTile(
                title: Text(v),
                onTap: () => Navigator.of(context).pop(v),
              ),
          ],
        );
      },
    );
    if (value != null) {
      setState(() => _filters[selectedType.id] = value);
    }
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow({
    required this.filters,
    required this.onAddFilter,
    required this.onRemove,
    required this.onClearAll,
  });

  final Map<String, String> filters;
  final VoidCallback onAddFilter;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(categoryTypesProvider);
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('All'),
            selected: filters.isEmpty,
            onSelected: (_) => onClearAll(),
          ),
          const SizedBox(width: 8),
          for (final entry in filters.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Builder(
                builder: (context) {
                  final type = types.firstWhere(
                    (t) => t.id == entry.key,
                    orElse: () => types.isEmpty
                        ? throw StateError('no types')
                        : types.first,
                  );
                  return InputChip(
                    avatar: CategoryTile(type: type, size: 20),
                    label: Text('${type.name}: ${entry.value}'),
                    onDeleted: () => onRemove(entry.key),
                  );
                },
              ),
            ),
          ActionChip(
            avatar: const Icon(Icons.tune, size: 18),
            label: const Text('Filter'),
            onPressed: onAddFilter,
          ),
          if (filters.isNotEmpty)
            TextButton(onPressed: onClearAll, child: const Text('Clear all')),
        ],
      ),
    );
  }
}

class _AssetCard extends ConsumerWidget {
  const _AssetCard({required this.asset, required this.onTap});

  final Asset asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final types = ref.watch(categoryTypesProvider);
    final typesById = {for (final t in types) t.id: t};

    final pairs = <MapEntry<CategoryType, String>>[];
    asset.propertyValues.forEach((typeId, value) {
      final type = typesById[typeId];
      if (type != null && !value.isEmpty) {
        pairs.add(MapEntry(type, value.displayString()));
      }
    });
    final shown = pairs.take(2).toList();
    final extra = pairs.length - shown.length;
    final thumbnail = _buildThumbnail(context, asset);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thumbnail != null) ...[
                thumbnail,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            asset.displayLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (asset.price != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            asset.price!.format(),
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ],
                    ),
                    if (asset.purchaseDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          DateFormat('d MMM y').format(asset.purchaseDate!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    for (final pair in shown)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: PropertyPairView(
                          type: pair.key,
                          value: pair.value,
                        ),
                      ),
                    if (extra > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Chip(
                          label: Text('+$extra more'),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 52×52 leading thumbnail: product photo if set, else the receipt image,
  /// else a PDF doc-icon tile when the receipt is a PDF.
  Widget? _buildThumbnail(BuildContext context, Asset asset) {
    final theme = Theme.of(context);
    String? imagePath;
    if (asset.productPhotoPath != null &&
        asset.productPhotoPath!.isNotEmpty) {
      imagePath = asset.productPhotoPath;
    } else if (asset.hasReceipt && !asset.receiptIsPdf) {
      imagePath = asset.receiptPhotoPath;
    }
    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(imagePath),
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) =>
              const SizedBox(width: 52, height: 52),
        ),
      );
    }
    if (asset.receiptIsPdf) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.picture_as_pdf_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return null;
  }
}

/// Inline type-color-icon tile + name + value pair used on cards and detail.
class PropertyPairView extends StatelessWidget {
  const PropertyPairView({super.key, required this.type, required this.value});

  final CategoryType type;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CategoryTile(type: type, size: 20),
        const SizedBox(width: 8),
        Text(
          '${type.name}: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text('No assets yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Track what you own — receipts, brands, models and more. '
              'Add your first asset to get started.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AssetFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add your first asset'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZeroResults extends StatelessWidget {
  const _ZeroResults();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text('No assets match', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Try a different search or clear your filters.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
