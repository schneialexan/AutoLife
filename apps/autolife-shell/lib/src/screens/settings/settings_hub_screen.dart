import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/shell_providers.dart';
import '../../router/shell_navigation.dart';
import '../../shell/shell_workspace_data.dart';
import '../auth/sessions_screen.dart';

/// Control-center entry tiles migrated from the legacy demo shell (phase 3.1).
class SettingsHubScreen extends ConsumerWidget {
  const SettingsHubScreen({super.key});

  static Tenant _effectiveTenant(ShellWorkspaceData ws) {
    if (!ws.tenancyResolved || ws.activeFamilyId.isEmpty) {
      return const Tenant(tenantId: 'local-dev');
    }
    return Tenant(tenantId: ws.activeFamilyId);
  }

  static FamilyRole? _activeFamilyRole(ShellWorkspaceData ws) {
    final id = ws.activeFamilyId;
    for (final e in ws.enrollments) {
      if (e.family.id == id) {
        return e.membership.role;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(shellWorkspaceProvider);
    final sync = ref.watch(syncStatusProvider);
    final connectors = ref.watch(connectorListProvider);
    final connectorStatuses = ref.watch(connectorStatusProvider);
    final title = _workspaceTitle(ws);

    final role = _activeFamilyRole(ws);
    final isOwner = role == FamilyRole.owner;
    final canResolveApprovals =
        role == FamilyRole.owner || role == FamilyRole.partner;

    final supabaseReachable = _supabaseReachable(ref);

    final tenant = _effectiveTenant(ws);

    final hubBody = supabaseReachable && ws.tenancyResolved
        ? _SupabaseSettingsBody(
            title: title,
            ws: ws,
            sync: sync,
            connectors: connectors,
            connectorStatuses: connectorStatuses,
            tenant: tenant,
            isOwner: isOwner,
            canResolveApprovals: canResolveApprovals,
          )
        : _OfflineSettingsBody(
            title: title,
            sync: sync,
            connectors: connectors,
            connectorStatuses: connectorStatuses,
            tenant: tenant,
          );

    return Padding(
      padding: const EdgeInsets.all(AutoLifeSpacing.md),
      child: hubBody,
    );
  }

  static String _workspaceTitle(ShellWorkspaceData ws) {
    final id = ws.activeFamilyId;
    for (final e in ws.enrollments) {
      if (e.family.id == id) {
        return e.family.name;
      }
    }
    return 'Settings';
  }

  static bool _supabaseReachable(WidgetRef ref) {
    try {
      ref.watch(supabaseClientProvider);
      return true;
    } on StateError catch (_) {
      return false;
    }
  }
}

class _SupabaseSettingsBody extends ConsumerWidget {
  const _SupabaseSettingsBody({
    required this.title,
    required this.ws,
    required this.sync,
    required this.connectors,
    required this.connectorStatuses,
    required this.tenant,
    required this.isOwner,
    required this.canResolveApprovals,
  });

  final String title;
  final ShellWorkspaceData ws;
  final SyncStatus sync;
  final List<String> connectors;
  final Map<String, ConnectorStatus> connectorStatuses;
  final Tenant tenant;
  final bool isOwner;
  final bool canResolveApprovals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        const Divider(),
        if (ws.activeFamilyId.isNotEmpty) ...[
          ListTile(
            leading: const Icon(Icons.grid_view_outlined),
            title: const Text('Role matrix'),
            subtitle: const Text(
              'Capability toggles per family role (owners edit).',
            ),
            onTap: () =>
                context.openRoleMatrix(ws, title, isOwner),
          ),
          ListTile(
            leading: const Icon(Icons.rule_folder_outlined),
            title: const Text('Approval queue'),
            subtitle: const Text('Pending parent/partner decisions.'),
            onTap: () =>
                context.openApprovalQueue(ws, title, canResolveApprovals),
          ),
          if (isOwner) ...[
            ListTile(
              leading: const Icon(Icons.fingerprint_outlined),
              title: const Text('Biometric locks'),
              subtitle: const Text(
                'Require device auth for sensitive modules.',
              ),
              onTap: () => context.openBiometricLocks(),
            ),
            ListTile(
              leading: const Icon(Icons.link_outlined),
              title: const Text('Babysitter link'),
              subtitle:
                  const Text('Share a scoped, expiring read-only token.'),
              onTap: () => context.openBabysitterLink(ws, title),
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.favorite_outline),
            title: const Text('Health (demo)'),
            subtitle:
                const Text('Biometric-gated placeholder for Phase 3.6.'),
            onTap: () => context.openHealthDemo(),
          ),
          const Divider(),
        ],
        ListTile(
          leading: const Icon(Icons.devices_other_outlined),
          title: const Text('Sessions & devices'),
          subtitle: Text(
            'Manage refresh tokens scoped to this client vs every signed-in shell.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const SessionsScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.refresh_outlined),
          title: const Text('Silent refresh probe'),
          onTap: () => context.silentRefreshProbe(ref.read(authServiceProvider)),
        ),
        const Divider(),
        Expanded(
          child: AutoLifeSurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(AutoLifeSpacing.md),
              child: SingleChildScrollView(
                child: _SyncSummary(
                  tenant: tenant,
                  sync: sync,
                  connectors: connectors,
                  connectorStatuses: connectorStatuses,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineSettingsBody extends StatelessWidget {
  const _OfflineSettingsBody({
    required this.title,
    required this.sync,
    required this.connectors,
    required this.connectorStatuses,
    required this.tenant,
  });

  final String title;
  final SyncStatus sync;
  final List<String> connectors;
  final Map<String, ConnectorStatus> connectorStatuses;
  final Tenant tenant;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AutoLifeSpacing.md),
        child: AutoLifeSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(AutoLifeSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AutoLifeSpacing.sm),
                _SyncSummary(
                  tenant: tenant,
                  sync: sync,
                  connectors: connectors,
                  connectorStatuses: connectorStatuses,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SyncSummary extends StatelessWidget {
  const _SyncSummary({
    required this.tenant,
    required this.sync,
    required this.connectors,
    required this.connectorStatuses,
  });

  final Tenant tenant;
  final SyncStatus sync;
  final List<String> connectors;
  final Map<String, ConnectorStatus> connectorStatuses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tenant: ${tenant.tenantId}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          'Sync: ${sync.phase.name} · pending ${sync.pendingQueueDepth}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          'Connectors: ${connectors.join(', ')}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (connectorStatuses.isNotEmpty) ...[
          const SizedBox(height: AutoLifeSpacing.xs),
          Text(
            connectorStatuses.entries
                .map((e) => '${e.key} → ${e.value.phase.name}')
                .join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (sync.lastError != null) ...[
          const SizedBox(height: AutoLifeSpacing.xs),
          Text(
            sync.lastError!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ],
    );
  }
}
