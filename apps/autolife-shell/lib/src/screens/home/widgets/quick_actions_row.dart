import 'dart:async';

import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../providers/shell_providers.dart';

/// Quick-create shortcuts publishing canonical bus envelopes (phase 3.1).
class QuickActionsRow extends ConsumerWidget {
  const QuickActionsRow({super.key});

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
      actorId: 'shell-quick-action',
      module: module,
      type: type,
      payload: payload,
      idempotencyKey: const Uuid().v4(),
      occurredAt: DateTime.now().toUtc(),
      orderingTag: '$module:${const Uuid().v4()}',
      schemaVersion: 1,
    );
    final res = await producer.publish(event);
    unawaited(ref.read(syncEngineProvider).runCycle());
    res.when<void>(
      success: (_) {},
      failure: (_) {},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.autoLifeTokens;
    return AutoLifeSurfaceCard(
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMd),
        // Dashboard rows can be shorter than title + buttons + padding; scroll
        // instead of overflowing (e.g. tight flex band or preview scale).
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quick actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: tokens.spaceSm),
              Wrap(
                spacing: tokens.spaceSm,
                runSpacing: tokens.spaceSm,
                children: [
                  AutoLifeButton(
                    key: const Key('quick_action_add_event'),
                    label: 'Add Event',
                    icon: Icons.event_available_outlined,
                    onPressed: () => _publish(
                      ref,
                      module: 'calendar',
                      type: 'event.created',
                      payload: const {
                        'title': 'New event',
                        'source': 'shell.quick_action',
                      },
                    ),
                  ),
                  AutoLifeButton(
                    key: const Key('quick_action_add_task'),
                    label: 'Add Task',
                    icon: Icons.task_alt_outlined,
                    onPressed: () => _publish(
                      ref,
                      module: 'tasks',
                      type: 'task.created',
                      payload: const {
                        'title': 'New task',
                        'source': 'shell.quick_action',
                      },
                    ),
                  ),
                  AutoLifeButton(
                    key: const Key('quick_action_scan_receipt'),
                    label: 'Scan Receipt',
                    icon: Icons.document_scanner_outlined,
                    onPressed: () => _publish(
                      ref,
                      module: 'assets',
                      type: 'asset.created',
                      payload: const {
                        'title': 'Receipt capture',
                        'source': 'shell.quick_action',
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final DashboardWidgetSpec quickActionsDashboardSpec = DashboardWidgetSpec(
  widgetId: 'quick_actions',
  moduleId: 'shell',
  title: 'Quick actions',
  supportedSizes: const [DashboardSize.m, DashboardSize.l, DashboardSize.xl],
  build: (context, slot) => const QuickActionsRow(),
);
