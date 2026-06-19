import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../models/asset.dart';
import '../../models/category_type.dart';
import '../../models/money.dart';
import '../../models/property_value.dart';
import '../../models/value_kind.dart';
import '../../providers/asset_providers.dart';
import '../../providers/category_type_providers.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/typed_field.dart';
import 'add_category_overlay.dart';

class AssetFormScreen extends ConsumerStatefulWidget {
  const AssetFormScreen({super.key, this.assetId});

  final String? assetId;

  @override
  ConsumerState<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends ConsumerState<AssetFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _purchaseDate;
  Money? _price;
  String? _receiptPhotoPath;

  /// Category fields currently on the form, in display order.
  final List<CategoryType> _addedTypes = <CategoryType>[];
  final Map<String, PropertyValue?> _values = <String, PropertyValue?>{};

  late final String _assetId;
  DateTime? _createdAt;

  /// Images stored during this editing session (cleaned up if not saved).
  final Set<String> _createdImages = <String>{};

  /// Image paths the loaded asset already referenced.
  final Set<String> _originalImages = <String>{};
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.assetId == null
        ? null
        : ref.read(assetByIdProvider(widget.assetId!));
    if (existing != null) {
      _assetId = existing.id;
      _createdAt = existing.createdAt;
      _nameController.text = existing.name ?? '';
      _purchaseDate = existing.purchaseDate;
      _price = existing.price;
      _receiptPhotoPath = existing.receiptPhotoPath;
      _originalImages.addAll(existing.imagePaths());

      final typesById = {
        for (final t in ref.read(categoryTypesProvider)) t.id: t,
      };
      existing.propertyValues.forEach((typeId, value) {
        final type = typesById[typeId];
        if (type != null) {
          _addedTypes.add(type);
          _values[typeId] = value;
        }
      });
    } else {
      _assetId = const Uuid().v4();
    }
  }

  @override
  void dispose() {
    if (!_saved) {
      final store = ref.read(assetImageStoreProvider);
      store.deleteAll(_createdImages);
    }
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditing => _createdAt != null;

  Future<String?> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) {
      return null;
    }
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) {
      return null;
    }
    final store = ref.read(assetImageStoreProvider);
    final stored = await store.saveImage(picked.path);
    _createdImages.add(stored);
    return stored;
  }

  void _onReceiptChanged(String? path) {
    _maybeDeleteReplaced(_receiptPhotoPath, path);
    setState(() => _receiptPhotoPath = path);
  }

  void _onPhotoValueChanged(String typeId, PropertyValue? value) {
    final old = _values[typeId];
    final oldPath = old is PhotoValue ? old.path : null;
    final newPath = value is PhotoValue ? value.path : null;
    _maybeDeleteReplaced(oldPath, newPath);
    setState(() => _values[typeId] = value);
  }

  /// Deletes a session-created image that was just replaced or cleared.
  void _maybeDeleteReplaced(String? oldPath, String? newPath) {
    if (oldPath == null || oldPath == newPath) {
      return;
    }
    if (_createdImages.contains(oldPath) &&
        !_originalImages.contains(oldPath)) {
      ref.read(assetImageStoreProvider).delete(oldPath);
      _createdImages.remove(oldPath);
    }
  }

  Future<void> _addCategory() async {
    final type = await showAddCategorySheet(
      context,
      excludeIds: _addedTypes.map((t) => t.id).toSet(),
    );
    if (type == null) {
      return;
    }
    setState(() {
      _addedTypes.add(type);
      _values[type.id] = null;
    });
  }

  void _removeCategory(CategoryType type) {
    final value = _values[type.id];
    if (value is PhotoValue) {
      _maybeDeleteReplaced(value.path, null);
    }
    setState(() {
      _addedTypes.removeWhere((t) => t.id == type.id);
      _values.remove(type.id);
    });
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final propertyValues = <String, PropertyValue>{};
    for (final type in _addedTypes) {
      final value = _values[type.id];
      if (value != null && !value.isEmpty) {
        propertyValues[type.id] = value;
      }
    }
    final name = _nameController.text.trim();
    final asset = Asset(
      id: _assetId,
      name: name.isEmpty ? null : name,
      purchaseDate: _purchaseDate,
      price: _price,
      receiptPhotoPath: _receiptPhotoPath,
      propertyValues: propertyValues,
      createdAt: _createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(assetsProvider.notifier).save(asset);

    // Reconcile orphaned images: anything created or originally present but no
    // longer referenced is deleted.
    final finalPaths = asset.imagePaths().toSet();
    final toDelete = <String>{..._createdImages, ..._originalImages}
      ..removeAll(finalPaths);
    await ref.read(assetImageStoreProvider).deleteAll(toDelete);

    _saved = true;
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assets = ref.watch(assetsProvider);
    final suggestionService = ref.watch(propertyValueSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit asset' : 'Add asset'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(onPressed: _save, child: const Text('Save')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _SectionTitle('Purchase'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('Name'),
                TextField(
                  controller: _nameController,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    isDense: true,
                    counterText: '',
                    border: OutlineInputBorder(),
                    hintText: 'Optional',
                  ),
                ),
                const SizedBox(height: 14),
                _FieldLabel('Date'),
                DatePickerField(
                  value: _purchaseDate,
                  onChanged: (date) => setState(() => _purchaseDate = date),
                ),
                const SizedBox(height: 14),
                _FieldLabel('Price'),
                MoneyField(
                  value: _price,
                  onChanged: (money) => setState(() => _price = money),
                ),
                const SizedBox(height: 14),
                _FieldLabel('Receipt photo'),
                PhotoDropzone(
                  path: _receiptPhotoPath,
                  onPickImage: _pickImage,
                  onChanged: _onReceiptChanged,
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Categories', style: theme.textTheme.titleMedium),
                      Text(
                        'Add only the fields you need for this asset.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Add category field',
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          if (_addedTypes.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'No category fields yet. Tap + to add one.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final type in _addedTypes)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: _CategoryFieldRow(
                type: type,
                value: _values[type.id],
                suggestions: suggestionService.suggestionsFor(
                  typeId: type.id,
                  valueKind: type.valueKind,
                  assets: assets,
                  excludeAssetId: _assetId,
                ),
                onPickImage: _pickImage,
                onChanged: (value) {
                  if (type.valueKind == ValueKind.photo) {
                    _onPhotoValueChanged(type.id, value);
                  } else {
                    setState(() => _values[type.id] = value);
                  }
                },
                onRemove: () => _removeCategory(type),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryFieldRow extends StatelessWidget {
  const _CategoryFieldRow({
    required this.type,
    required this.value,
    required this.suggestions,
    required this.onChanged,
    required this.onRemove,
    required this.onPickImage,
  });

  final CategoryType type;
  final PropertyValue? value;
  final List<String> suggestions;
  final ValueChanged<PropertyValue?> onChanged;
  final VoidCallback onRemove;
  final ImagePickerCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CategoryTile(type: type, size: 22),
            const SizedBox(width: 8),
            Text(type.name, style: theme.textTheme.labelLarge),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                type.valueKind.label,
                style: theme.textTheme.labelSmall,
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Remove ${type.name}',
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TypedField(
          key: ValueKey(type.id),
          type: type,
          value: value,
          suggestions: suggestions,
          onPickImage: onPickImage,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
