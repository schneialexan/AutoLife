import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../models/asset.dart';
import '../models/category_type.dart';
import '../providers/asset_providers.dart';
import '../providers/category_type_providers.dart';
import '../widgets/typed_field.dart';
import 'asset_form/asset_form_screen.dart';
import 'vault/vault_screen.dart';

class AssetDetailScreen extends ConsumerWidget {
  const AssetDetailScreen({super.key, required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asset = ref.watch(assetByIdProvider(assetId));

    if (asset == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Asset not found.')),
      );
    }

    final types = ref.watch(categoryTypesProvider);
    final typesById = {for (final t in types) t.id: t};
    final pairs = <MapEntry<CategoryType, String>>[];
    asset.propertyValues.forEach((typeId, value) {
      final type = typesById[typeId];
      if (type != null && !value.isEmpty) {
        pairs.add(MapEntry(type, value.displayString()));
      }
    });

    final hasProductPhoto =
        asset.productPhotoPath != null && asset.productPhotoPath!.isNotEmpty;
    final hasPurchase =
        asset.price != null ||
        asset.purchaseDate != null ||
        asset.hasName ||
        asset.hasReceipt;
    final warrantyDocs = asset.warrantyDocuments
        .where((d) => d.path.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.displayLabel),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AssetFormScreen(assetId: asset.id),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'More actions',
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context, ref, asset);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          if (hasProductPhoto)
            Image.file(
              File(asset.productPhotoPath!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
            ),
          if (hasPurchase) ...[
            _SectionTitle('Purchase'),
            if (asset.price != null)
              _DetailRow(label: 'Price', value: asset.price!.format()),
            if (asset.hasName)
              _DetailRow(label: 'Name', value: asset.name!.trim()),
            if (asset.purchaseDate != null)
              _DetailRow(
                label: 'Date',
                value: DateFormat('d MMM y').format(asset.purchaseDate!),
              ),
            if (asset.hasReceipt)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: asset.receiptIsPdf
                    ? DocumentTile(
                        title: 'Receipt (PDF)',
                        subtitle: 'Tap to open',
                        isPdf: true,
                        onOpen: () => OpenFilex.open(asset.receiptPhotoPath!),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(asset.receiptPhotoPath!),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const SizedBox.shrink(),
                        ),
                      ),
              ),
          ],
          if (pairs.isNotEmpty) ...[
            _SectionTitle('Categories'),
            for (final pair in pairs)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: PropertyPairView(type: pair.key, value: pair.value),
              ),
          ],
          if (warrantyDocs.isNotEmpty) ...[
            _SectionTitle('Warranty'),
            for (final doc in warrantyDocs)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: DocumentTile(
                  title: doc.name,
                  isPdf: doc.isPdf,
                  onOpen: () => OpenFilex.open(doc.path),
                ),
              ),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Added ${DateFormat('d MMM y').format(asset.createdAt)} '
              '\u00b7 Updated ${DateFormat('d MMM y').format(asset.updatedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Asset asset,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${asset.displayLabel}?'),
        content: const Text('This permanently removes the asset.'),
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
    if (!(confirmed ?? false)) {
      return;
    }
    await ref.read(assetsProvider.notifier).delete(asset.id);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
