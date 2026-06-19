import 'package:flutter/material.dart';

import '../models/category_type.dart';

/// Add / rename / remove the allowed choices for a Select type. Removal of an
/// option currently used by an asset is blocked with a tooltip.
class SelectOptionsEditor extends StatefulWidget {
  const SelectOptionsEditor({
    super.key,
    required this.initialOptions,
    required this.onChanged,
    this.usedOptions = const <String>{},
  });

  final List<String> initialOptions;
  final ValueChanged<List<String>> onChanged;

  /// Option labels that are in use and therefore cannot be removed.
  final Set<String> usedOptions;

  @override
  State<SelectOptionsEditor> createState() => _SelectOptionsEditorState();
}

class _SelectOptionsEditorState extends State<SelectOptionsEditor> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialOptions.isEmpty
        ? <String>['', '']
        : widget.initialOptions;
    _controllers = seed.map((o) => TextEditingController(text: o)).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(_controllers.map((c) => c.text.trim()).toList());
  }

  void _addOption() {
    if (_controllers.length >= CategoryType.maxOptions) {
      return;
    }
    setState(() => _controllers.add(TextEditingController()));
    _emit();
  }

  void _removeOption(int index) {
    final removed = _controllers.removeAt(index);
    removed.dispose();
    setState(() {});
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options (min ${CategoryType.minOptions}, max ${CategoryType.maxOptions})',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _controllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OptionRow(
              controller: _controllers[i],
              inUse: widget.usedOptions.contains(_controllers[i].text.trim()),
              canRemove: _controllers.length > 1,
              onChanged: _emit,
              onRemove: () => _removeOption(i),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _controllers.length >= CategoryType.maxOptions
                ? null
                : _addOption,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add option'),
          ),
        ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.controller,
    required this.inUse,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final TextEditingController controller;
  final bool inUse;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final removable = canRemove && !inUse;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLength: CategoryType.maxOptionLength,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              isDense: true,
              counterText: '',
              border: OutlineInputBorder(),
              hintText: 'Option label',
            ),
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: inUse
              ? 'In use on an asset — cannot remove'
              : 'Remove option',
          child: IconButton(
            onPressed: removable ? onRemove : null,
            icon: const Icon(Icons.close, size: 18),
          ),
        ),
      ],
    );
  }
}
