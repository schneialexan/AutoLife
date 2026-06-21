import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uuid/uuid.dart';

import '../../models/asset.dart';
import '../../models/asset_document.dart';
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
  String? _productPhotoPath;
  final List<AssetDocument> _warrantyDocuments = <AssetDocument>[];

  /// Category fields currently on the form, in display order.
  final List<CategoryType> _addedTypes = <CategoryType>[];
  final Map<String, PropertyValue?> _values = <String, PropertyValue?>{};

  late final String _assetId;
  DateTime? _createdAt;

  /// Images stored during this editing session (cleaned up if not saved).
  final Set<String> _createdImages = <String>{};

  /// Non-image files (PDFs) stored during this session.
  final Set<String> _createdFiles = <String>{};

  /// File paths the loaded asset already referenced.
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
      _productPhotoPath = existing.productPhotoPath;
      _warrantyDocuments.addAll(existing.warrantyDocuments);
      _originalImages.addAll(existing.localFilePaths());

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
      store.deleteAll(<String>{..._createdImages, ..._createdFiles});
    }
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditing => _createdAt != null;

  /// Image-only picker (camera/gallery) for product photo and Photo categories.
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

  /// Prompts for an image URL, downloads it locally, and returns the new path.
  Future<String?> _pasteImageUrl() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paste image URL'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://example.com/photo.jpg',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Download'),
          ),
        ],
      ),
    );
    controller.dispose();
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    final store = ref.read(assetImageStoreProvider);
    final stored = await store.saveImageFromUrl(trimmed);
    if (stored == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not download a JPEG or PNG from that URL.'),
          ),
        );
      }
      return null;
    }
    _createdImages.add(stored);
    return stored;
  }

  /// Receipt source picker: photo, gallery, PDF/file, or deferred QR/link.
  Future<String?> _pickReceipt() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take photo'),
                onTap: () => Navigator.of(context).pop('camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Choose PDF / file'),
                onTap: () => Navigator.of(context).pop('file'),
              ),
              ListTile(
                enabled: false,
                leading: const Icon(Icons.qr_code_scanner_outlined),
                title: const Text('From QR / link'),
                trailing: Chip(
                  label: const Text('Soon'),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        );
      },
    );
    if (action == null) {
      return null;
    }
    final store = ref.read(assetImageStoreProvider);
    if (action == 'file') {
      final path = await _pickDocumentPath();
      if (path == null) {
        return null;
      }
      final stored = await store.saveFile(path);
      _createdFiles.add(stored);
      return stored;
    }
    final picked = await ImagePicker().pickImage(
      source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
    );
    if (picked == null) {
      return null;
    }
    final stored = await store.saveImage(picked.path);
    _createdImages.add(stored);
    return stored;
  }

  /// Picks a PDF/image file and returns its source path (not yet stored).
  Future<String?> _pickDocumentPath() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    return result?.files.single.path;
  }

  /// Picks a warranty file, stores it, and returns the new document.
  Future<AssetDocument?> _addWarrantyDoc() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final picked = result?.files.single;
    final source = picked?.path;
    if (picked == null || source == null) {
      return null;
    }
    final store = ref.read(assetImageStoreProvider);
    final stored = await store.saveFile(source);
    _createdFiles.add(stored);
    final doc = AssetDocument(path: stored, name: picked.name);
    setState(() => _warrantyDocuments.add(doc));
    return doc;
  }

  void _removeWarrantyDoc(int index) {
    if (index < 0 || index >= _warrantyDocuments.length) {
      return;
    }
    final removed = _warrantyDocuments[index];
    _maybeDeleteReplaced(removed.path, null);
    setState(() => _warrantyDocuments.removeAt(index));
  }

  Future<void> _openDocument(String path) async {
    await OpenFilex.open(path);
  }

  void _onReceiptChanged(String? path) {
    _maybeDeleteReplaced(_receiptPhotoPath, path);
    setState(() => _receiptPhotoPath = path);
  }

  void _onProductPhotoChanged(String? path) {
    _maybeDeleteReplaced(_productPhotoPath, path);
    setState(() => _productPhotoPath = path);
  }

  void _onPhotoValueChanged(String typeId, PropertyValue? value) {
    final old = _values[typeId];
    final oldPath = old is PhotoValue ? old.path : null;
    final newPath = value is PhotoValue ? value.path : null;
    _maybeDeleteReplaced(oldPath, newPath);
    setState(() => _values[typeId] = value);
  }

  /// Deletes a session-created file that was just replaced or cleared.
  void _maybeDeleteReplaced(String? oldPath, String? newPath) {
    if (oldPath == null || oldPath == newPath) {
      return;
    }
    if (_originalImages.contains(oldPath)) {
      return;
    }
    if (_createdImages.contains(oldPath) || _createdFiles.contains(oldPath)) {
      ref.read(assetImageStoreProvider).delete(oldPath);
      _createdImages.remove(oldPath);
      _createdFiles.remove(oldPath);
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
      productPhotoPath: _productPhotoPath,
      warrantyDocuments: List<AssetDocument>.of(_warrantyDocuments),
      propertyValues: propertyValues,
      createdAt: _createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(assetsProvider.notifier).save(asset);

    // Reconcile orphaned files: anything created or originally present but no
    // longer referenced is deleted.
    final finalPaths = asset.localFilePaths().toSet();
    final toDelete = <String>{
      ..._createdImages,
      ..._createdFiles,
      ..._originalImages,
    }..removeAll(finalPaths);
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
                _FieldLabel('Product photo'),
                ProductPhotoField(
                  path: _productPhotoPath,
                  onPickImage: _pickImage,
                  onPasteUrl: _pasteImageUrl,
                  onChanged: _onProductPhotoChanged,
                ),
                const SizedBox(height: 14),
                _FieldLabel('Receipt'),
                ReceiptField(
                  path: _receiptPhotoPath,
                  isPdf:
                      _receiptPhotoPath != null &&
                      _receiptPhotoPath!.toLowerCase().endsWith('.pdf'),
                  onPick: _pickReceipt,
                  onChanged: _onReceiptChanged,
                  onOpen: _receiptPhotoPath == null
                      ? null
                      : () => _openDocument(_receiptPhotoPath!),
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
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Warranty', style: theme.textTheme.titleMedium),
                Text(
                  'Store warranty proof — PDF or photo. Saved locally on device.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                WarrantyDocsField(
                  documents: _warrantyDocuments,
                  onAdd: _addWarrantyDoc,
                  onRemove: _removeWarrantyDoc,
                  onOpen: (doc) => _openDocument(doc.path),
                ),
              ],
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
