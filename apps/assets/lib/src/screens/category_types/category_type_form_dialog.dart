import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../constants/category_colors.dart';
import '../../constants/category_icons.dart';
import '../../data/category_type_repository.dart';
import '../../models/category_type.dart';
import '../../models/property_value.dart';
import '../../models/value_kind.dart';
import '../../providers/asset_providers.dart';
import '../../providers/category_type_providers.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/color_swatch_picker.dart';
import '../../widgets/icon_picker_sheet.dart';
import '../../widgets/select_options_editor.dart';

/// Opens the create/edit type sheet. Returns the saved [CategoryType], or null
/// if the user cancelled.
Future<CategoryType?> showCategoryTypeForm(
  BuildContext context, {
  CategoryType? existing,
}) {
  return showModalBottomSheet<CategoryType>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: _CategoryTypeFormSheet(existing: existing),
      ),
    ),
  );
}

class _CategoryTypeFormSheet extends ConsumerStatefulWidget {
  const _CategoryTypeFormSheet({this.existing});

  final CategoryType? existing;

  @override
  ConsumerState<_CategoryTypeFormSheet> createState() =>
      _CategoryTypeFormSheetState();
}

class _CategoryTypeFormSheetState
    extends ConsumerState<_CategoryTypeFormSheet> {
  late final TextEditingController _nameController;
  late ValueKind _kind;
  late String _color;
  late String _icon;
  List<String> _options = <String>[];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _kind = existing?.valueKind ?? ValueKind.text;
    _color = existing?.accentColor ?? CategoryColors.defaultColor;
    _icon = existing?.displayIcon ?? CategoryIcons.defaultIcon;
    _options = List<String>.from(existing?.options ?? const <String>[]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existing != null;

  bool get _kindLocked {
    if (!_isEditing) {
      return false;
    }
    final usage = ref.read(typeUsageProvider)[widget.existing!.id] ?? 0;
    return usage > 0;
  }

  Set<String> get _usedOptionValues {
    final existing = widget.existing;
    if (existing == null) {
      return <String>{};
    }
    final assets = ref.read(assetsProvider);
    final used = <String>{};
    for (final asset in assets) {
      final value = asset.propertyValues[existing.id];
      if (value is SelectValue && value.value.isNotEmpty) {
        used.add(value.value);
      }
    }
    return used;
  }

  String? _validate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return 'Enter a name';
    }
    if (name.length > CategoryType.maxNameLength) {
      return 'Name is too long';
    }
    if (_kind == ValueKind.select) {
      final cleaned = _options.map((o) => o.trim()).where((o) => o.isNotEmpty);
      final unique = cleaned.toSet();
      if (unique.length < CategoryType.minOptions) {
        return 'Add at least ${CategoryType.minOptions} options';
      }
      if (unique.length != cleaned.length) {
        return 'Options must be unique';
      }
    }
    return null;
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final notifier = ref.read(categoryTypesProvider.notifier);
    final name = _nameController.text.trim();
    final options = _kind == ValueKind.select
        ? _options.map((o) => o.trim()).where((o) => o.isNotEmpty).toList()
        : null;

    final CategoryType type;
    if (_isEditing) {
      type = widget.existing!.copyWith(
        name: name,
        valueKind: _kind,
        options: options,
        clearOptions: _kind != ValueKind.select,
        accentColor: _color,
        displayIcon: _icon,
      );
    } else {
      type = CategoryType(
        id: const Uuid().v4(),
        name: name,
        valueKind: _kind,
        options: options,
        accentColor: _color,
        displayIcon: _icon,
        sortOrder: notifier.nextSortOrder(),
        createdAt: DateTime.now(),
      );
    }

    try {
      await notifier.save(type);
    } on CategoryTypeLimitException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).pop(type);
    }
  }

  Future<void> _pickIcon() async {
    final selected = await showIconPickerSheet(
      context,
      selected: _icon,
      accentColor: _color,
    );
    if (selected != null) {
      setState(() => _icon = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Row(
            children: [
              CategoryTile(
                type: CategoryType(
                  id: 'preview',
                  name: 'preview',
                  valueKind: _kind,
                  accentColor: _color,
                  displayIcon: _icon,
                  sortOrder: 0,
                  createdAt: DateTime.now(),
                ),
                size: 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isEditing ? 'Edit type' : 'New category type',
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              _Label('Name'),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconTrigger(
                    iconKey: _icon,
                    accentColor: _color,
                    onTap: _pickIcon,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      maxLength: CategoryType.maxNameLength,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        hintText: 'e.g. Brand',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Label('Value kind'),
                  if (_kindLocked) ...[
                    const SizedBox(width: 8),
                    Tooltip(
                      message:
                          'In use by assets — archive and create a new type',
                      child: Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final kind in ValueKind.values)
                    ChoiceChip(
                      label: Text(kind.label),
                      selected: _kind == kind,
                      onSelected: _kindLocked
                          ? null
                          : (_) => setState(() => _kind = kind),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _Label('Color'),
              const SizedBox(height: 6),
              ColorSwatchPicker(
                selected: _color,
                onSelected: (c) => setState(() => _color = c),
              ),
              if (_kind == ValueKind.select) ...[
                const SizedBox(height: 16),
                SelectOptionsEditor(
                  initialOptions: _options,
                  usedOptions: _usedOptionValues,
                  onChanged: (options) => _options = options,
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save' : 'Create type'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Clickable swatch sitting to the left of the Name field that previews the
/// selected icon and opens the icon picker sheet when tapped.
class _IconTrigger extends StatelessWidget {
  const _IconTrigger({
    required this.iconKey,
    required this.accentColor,
    required this.onTap,
  });

  final String iconKey;
  final String accentColor;
  final VoidCallback onTap;

  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = CategoryColors.parse(accentColor);
    return Semantics(
      label: 'Choose icon',
      button: true,
      child: Tooltip(
        message: 'Choose icon',
        child: Material(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: _size,
              height: _size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CategoryIconView(iconKey: iconKey, color: accent, size: 24),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Icon(
                      Icons.edit,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
