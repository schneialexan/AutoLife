import 'dart:async';

import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../providers/shell_providers.dart';

/// Minimal create-event screen for phase 1.8 smoke (debug / Supabase modes).
class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _controller = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    setState(() => _busy = true);
    final producer = ref.read(shellEventProducerProvider);
    final tenant = ref.read(shellTenantIdProvider);
    final event = SystemEvent(
      tenantId: tenant,
      actorId: 'shell-smoke',
      module: 'smoke',
      type: 'smoke.note',
      payload: {
        'title': title,
        if (title.contains('flaky')) 'smoke_flaky': true,
      },
      idempotencyKey: const Uuid().v4(),
      occurredAt: DateTime.now().toUtc(),
      orderingTag: 'smoke:${const Uuid().v4()}',
      schemaVersion: 1,
    );
    final result = await producer.publish(event);
    if (!mounted) return;
    setState(() => _busy = false);
    result.when(
      success: (_) {
        _controller.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event queued or published')),
        );
        unawaited(ref.read(syncEngineProvider).runCycle());
      },
      failure: (f) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${f.message}')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.autoLifeTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add Event',
          key: const Key('smoke_add_heading'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: tokens.spaceMd),
        TextField(
          key: const Key('smoke_add_title_field'),
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'Smoke event title',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _busy ? null : _submit(),
        ),
        SizedBox(height: tokens.spaceMd),
        AutoLifeButton(
          label: _busy ? 'Working…' : 'Add Event',
          onPressed: _busy ? null : _submit,
          icon: Icons.add,
        ),
      ],
    );
  }
}
