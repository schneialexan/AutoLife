import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/category_type.dart';
import '../models/money.dart';
import '../models/property_value.dart';
import '../models/value_kind.dart';

/// Picks an image, stores it, and returns the new local path (or null).
typedef ImagePickerCallback = Future<String?> Function();

/// Renders the correct input affordance for a category type's value kind and
/// reports changes as a [PropertyValue] (or null when cleared/empty).
class TypedField extends StatefulWidget {
  const TypedField({
    super.key,
    required this.type,
    required this.value,
    required this.onChanged,
    this.suggestions = const <String>[],
    this.onPickImage,
  });

  final CategoryType type;
  final PropertyValue? value;
  final ValueChanged<PropertyValue?> onChanged;
  final List<String> suggestions;
  final ImagePickerCallback? onPickImage;

  @override
  State<TypedField> createState() => _TypedFieldState();
}

class _TypedFieldState extends State<TypedField> {
  TextEditingController? _textController;

  @override
  void initState() {
    super.initState();
    final kind = widget.type.valueKind;
    if (kind == ValueKind.text || kind == ValueKind.number) {
      _textController = TextEditingController(
        text: switch (widget.value) {
          TextValue(value: final v) => v,
          NumberValue() => widget.value!.displayString(),
          _ => '',
        },
      );
    }
  }

  @override
  void dispose() {
    _textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type.valueKind) {
      case ValueKind.text:
        return _buildText(context);
      case ValueKind.number:
        return _buildNumber();
      case ValueKind.date:
        return DatePickerField(
          value: switch (widget.value) {
            DateValue(value: final v) => v,
            _ => null,
          },
          onChanged: (date) =>
              widget.onChanged(date == null ? null : DateValue(date)),
        );
      case ValueKind.money:
        return MoneyField(
          value: switch (widget.value) {
            MoneyValue(value: final v) => v,
            _ => null,
          },
          onChanged: (money) =>
              widget.onChanged(money == null ? null : MoneyValue(money)),
        );
      case ValueKind.photo:
        return PhotoDropzone(
          path: switch (widget.value) {
            PhotoValue(path: final p) => p,
            _ => null,
          },
          onPickImage: widget.onPickImage,
          onChanged: (path) =>
              widget.onChanged(path == null ? null : PhotoValue(path)),
        );
      case ValueKind.select:
        return _buildSelect();
    }
  }

  Widget _buildText(BuildContext context) {
    final query = _textController!.text.trim().toLowerCase();
    final matches = widget.suggestions
        .where((s) => s.toLowerCase() != query)
        .where((s) => query.isEmpty || s.toLowerCase().contains(query))
        .take(6)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textController,
          maxLength: 64,
          decoration: const InputDecoration(
            isDense: true,
            counterText: '',
            border: OutlineInputBorder(),
            hintText: 'Optional',
          ),
          onChanged: (text) {
            setState(() {});
            widget.onChanged(text.trim().isEmpty ? null : TextValue(text));
          },
        ),
        if (matches.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final s in matches)
                  ActionChip(
                    label: Text(s),
                    onPressed: () {
                      _textController!.text = s;
                      _textController!.selection = TextSelection.collapsed(
                        offset: s.length,
                      );
                      setState(() {});
                      widget.onChanged(TextValue(s));
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNumber() {
    return TextField(
      controller: _textController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
        hintText: '0',
      ),
      onChanged: (text) {
        final parsed = double.tryParse(text.replaceAll(',', '.'));
        widget.onChanged(parsed == null ? null : NumberValue(parsed));
      },
    );
  }

  Widget _buildSelect() {
    final options = widget.type.options ?? const <String>[];
    final current = switch (widget.value) {
      SelectValue(value: final v) => options.contains(v) ? v : null,
      _ => null,
    };
    return DropdownButtonFormField<String>(
      initialValue: current,
      isExpanded: true,
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
        hintText: 'Choose one',
      ),
      items: [
        for (final option in options)
          DropdownMenuItem<String>(value: option, child: Text(option)),
      ],
      onChanged: (value) =>
          widget.onChanged(value == null ? null : SelectValue(value)),
    );
  }
}

/// Amount field + currency dropdown.
class MoneyField extends StatefulWidget {
  const MoneyField({super.key, required this.value, required this.onChanged});

  final Money? value;
  final ValueChanged<Money?> onChanged;

  @override
  State<MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  late final TextEditingController _amountController;
  late String _currency;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.value == null ? '' : widget.value!.amount.toStringAsFixed(2),
    );
    _currency = widget.value?.currency ?? Money.supportedCurrencies.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _emit() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    widget.onChanged(
      amount == null ? null : Money(amount: amount, currency: _currency),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              hintText: '0.00',
            ),
            onChanged: (_) => _emit(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            initialValue: _currency,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: [
              for (final code in Money.supportedCurrencies)
                DropdownMenuItem<String>(value: code, child: Text(code)),
            ],
            onChanged: (code) {
              if (code == null) {
                return;
              }
              setState(() => _currency = code);
              _emit();
            },
          ),
        ),
      ],
    );
  }
}

/// Read-only field with a trailing calendar icon that opens the date picker.
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = value == null
        ? 'Optional'
        : DateFormat('d MMM y').format(value!);
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(2000),
          lastDate: DateTime(now.year + 5),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          suffixIcon: value == null
              ? const Icon(Icons.event_outlined)
              : IconButton(
                  tooltip: 'Clear date',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => onChanged(null),
                ),
        ),
        child: Text(
          label,
          style: value == null
              ? theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)
              : theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}

/// Camera/gallery dropzone with preview and remove.
class PhotoDropzone extends StatelessWidget {
  const PhotoDropzone({
    super.key,
    required this.path,
    required this.onChanged,
    this.onPickImage,
  });

  final String? path;
  final ValueChanged<String?> onChanged;
  final ImagePickerCallback? onPickImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhoto = path != null && path!.isNotEmpty;
    return InkWell(
      onTap: onPickImage == null
          ? null
          : () async {
              final newPath = await onPickImage!();
              if (newPath != null) {
                onChanged(newPath);
              }
            },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            style: hasPhoto ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: hasPhoto
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(path!),
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          const SizedBox(height: 160),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Remove photo',
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => onChanged(null),
                      ),
                    ),
                  ),
                ],
              )
            : DottedDropzonePlaceholder(),
      ),
    );
  }
}

class DottedDropzonePlaceholder extends StatelessWidget {
  const DottedDropzonePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Tap to add photo (JPEG or PNG)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
