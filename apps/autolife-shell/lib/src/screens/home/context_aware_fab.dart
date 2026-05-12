import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../providers/shell_providers.dart';
import 'package:autolife_core/autolife_core.dart';

/// Floating action mapped to the active shell branch (phase 3.1).
class ContextAwareFab extends ConsumerWidget {
  const ContextAwareFab({super.key, required this.branchIndex});

  final int branchIndex;

  Future<void> _publish(
    WidgetRef ref, {
    required String module,
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    final producer = ref.read(shellEventProducerProvider);
    final tenant = ref.read(shellTenantIdProvider);
    final event = SystemEvent(
      tenantId: tenant,
      actorId: 'shell-fab',
      module: module,
      type: type,
      payload: payload,
      idempotencyKey: const Uuid().v4(),
      occurredAt: DateTime.now().toUtc(),
      orderingTag: '$module:${const Uuid().v4()}',
      schemaVersion: 1,
    );
    final res = await producer.publish(event);
    await ref.read(syncEngineProvider).runCycle();
    res.when(
      success: (_) {},
      failure: (_) {},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (branchIndex > 3) return const SizedBox.shrink();

    late final String label;
    late final VoidCallback onPressed;

    switch (branchIndex) {
      case 0:
      case 1:
        label = 'Add event';
        onPressed = () => _publish(
              ref,
              module: 'calendar',
              type: 'event.created',
              payload: const {
                'title': 'FAB event',
                'source': 'shell.fab',
              },
            );
        break;
      case 2:
        label = 'Add task';
        onPressed = () => _publish(
              ref,
              module: 'tasks',
              type: 'task.created',
              payload: const {
                'title': 'FAB task',
                'source': 'shell.fab',
              },
            );
        break;
      case 3:
      default:
        label = 'Scan asset';
        onPressed = () => _publish(
              ref,
              module: 'assets',
              type: 'asset.created',
              payload: const {
                'title': 'FAB asset capture',
                'source': 'shell.fab',
              },
            );
    }

    return FloatingActionButton.extended(
      key: const Key('context_aware_fab'),
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(label),
    );
  }
}
