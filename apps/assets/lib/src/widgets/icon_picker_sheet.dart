import 'package:flutter/material.dart';

import 'icon_grid_picker.dart';

/// Opens a modal bottom sheet that lets the user search and pick a catalog icon
/// or emoji. Returns the selected icon key (e.g. `icon:tag`), or null if the
/// sheet was dismissed without a choice.
Future<String?> showIconPickerSheet(
  BuildContext context, {
  required String selected,
  required String accentColor,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: _IconPickerSheet(selected: selected, accentColor: accentColor),
      ),
    ),
  );
}

class _IconPickerSheet extends StatefulWidget {
  const _IconPickerSheet({required this.selected, required this.accentColor});

  final String selected;
  final String accentColor;

  @override
  State<_IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<_IconPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text('Choose an icon', style: theme.textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search icons',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: IconGridPicker(
              selected: widget.selected,
              accentColor: widget.accentColor,
              query: _query,
              onSelected: (key) => Navigator.of(context).pop(key),
            ),
          ),
        ),
      ],
    );
  }
}
