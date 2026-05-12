import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';

/// Bottom sheet for editing [CalendarRecurrenceRule]; returns rule on Done, or null if cleared.
class RecurrenceEditorSheet extends StatefulWidget {
  const RecurrenceEditorSheet({super.key, this.initial});

  final CalendarRecurrenceRule? initial;

  @override
  State<RecurrenceEditorSheet> createState() => _RecurrenceEditorSheetState();
}

class _RecurrenceEditorSheetState extends State<RecurrenceEditorSheet> {
  late RecurrenceFrequency _freq;
  late int _interval;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _freq = i?.frequency ?? RecurrenceFrequency.weekly;
    _interval = i?.interval ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Recurrence', style: Theme.of(context).textTheme.titleLarge),
          DropdownButton<RecurrenceFrequency>(
            value: _freq,
            items: RecurrenceFrequency.values
                .map(
                  (f) => DropdownMenuItem(
                    value: f,
                    child: Text(f.name),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _freq = v ?? _freq),
          ),
          Row(
            children: [
              const Text('Every'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _interval,
                items: List.generate(
                  10,
                  (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                ),
                onChanged: (v) => setState(() => _interval = v ?? 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop<CalendarRecurrenceRule?>(context, null),
            child: const Text('Does not repeat'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              final initial = widget.initial;
              Navigator.pop<CalendarRecurrenceRule?>(
                context,
                CalendarRecurrenceRule(
                  frequency: _freq,
                  interval: _interval,
                  byWeekday: initial?.byWeekday ?? const [],
                  until: initial?.until,
                  count: initial?.count,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
