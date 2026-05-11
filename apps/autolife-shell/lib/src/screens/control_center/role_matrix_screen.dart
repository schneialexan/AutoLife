import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/providers/shell_providers.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owner-only editors for `capability_grants` seeded from YAML defaults (Phase 2.3).
class RoleMatrixScreen extends ConsumerStatefulWidget {
  const RoleMatrixScreen({
    super.key,
    required this.familyId,
    required this.familyName,
    required this.isOwner,
  });

  final String familyId;
  final String familyName;
  final bool isOwner;

  @override
  ConsumerState<RoleMatrixScreen> createState() => _RoleMatrixScreenState();
}

class _RoleMatrixScreenState extends ConsumerState<RoleMatrixScreen> {
  var _loading = false;
  var _error = '';
  List<Map<String, dynamic>> _rows = const [];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(load);
  }

  Future<void> load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final client = ref.read(supabaseClientProvider);
      final data = await client
          .from('capability_grants')
          .select()
          .eq('family_id', widget.familyId)
          .order('capability');

      final list = <Map<String, dynamic>>[];
      for (final raw in data as List<dynamic>) {
        list.add(Map<String, dynamic>.from(raw as Map));
      }
      list.sort((a, b) {
        final cc = '${a['capability']}'.compareTo('${b['capability']}');
        if (cc != 0) return cc;
        return '${a['role']}'.compareTo('${b['role']}');
      });
      if (mounted) {
        setState(() {
          _rows = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
        });
      }
    }
  }

  CapabilityGrantDefaults _defaults(FamilyRole role, Capability capability) =>
      defaultsFor(role, capability);

  Future<void> _patchRoleRow({
    required FamilyRole role,
    required Capability capability,
    required bool granted,
    required bool reqAp,
    required bool photo,
    required bool verified,
  }) async {
    if (!widget.isOwner) return;
    setState(() => _loading = true);
    try {
      final client = ref.read(supabaseClientProvider);
      final res = await persistCapabilityGrantPatch(
        client: client,
        patch: CapabilityUpdate(
          familyId: widget.familyId,
          role: role,
          capability: capability,
          granted: granted,
          requiresParentApproval: reqAp,
          requirePhotoProof: photo,
          requireParentVerification: verified,
        ),
      );
      await res.when(
        success: (_) async {
          if (mounted) await load();
        },
        failure: (f) async {
          if (!mounted) return;
          setState(() {
            _error = f.message ?? f.code;
            _loading = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  CapabilityGrantDefaults _fromRow(Map<String, dynamic> snapshot) =>
      CapabilityGrantDefaults(
        granted: snapshot['granted'] as bool,
        requiresParentApproval: snapshot['requires_parent_approval'] as bool,
        requirePhotoProof: snapshot['require_photo_proof'] as bool,
        requireParentVerification:
            snapshot['require_parent_verification'] as bool,
      );

  Map<String, dynamic>? _dbRow(FamilyRole role, Capability capability) {
    for (final m in _rows) {
      if (m['capability'] == capability.wireValue && m['role'] == role.name) {
        return m;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roles · ${widget.familyName}'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading && _rows.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final banner = !widget.isOwner
        ? 'Only household owners edit the matrix.'
        : _error.isNotEmpty
        ? _error
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (banner != null)
          Padding(
            padding: const EdgeInsets.all(AutoLifeSpacing.md),
            child: Text(
              banner,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        Expanded(
          child: ListView(
            children: [
              for (final capability in Capability.values)
                ExpansionTile(
                  initiallyExpanded: capability.index < 2,
                  title: Text(capability.wireValue),
                  children: [
                    for (final role in FamilyRole.values)
                      _roleCard(context, capability, role),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roleCard(
    BuildContext context,
    Capability capability,
    FamilyRole role,
  ) {
    final snapshot = _dbRow(role, capability);
    final grant = snapshot == null
        ? _defaults(role, capability)
        : _fromRow(snapshot);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AutoLifeSpacing.sm,
        vertical: AutoLifeSpacing.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AutoLifeSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role.name, style: Theme.of(context).textTheme.titleSmall),
            SwitchListTile(
              title: const Text('Granted'),
              value: grant.granted,
              onChanged: widget.isOwner
                  ? (v) => _patchRoleRow(
                      role: role,
                      capability: capability,
                      granted: v,
                      reqAp: grant.requiresParentApproval,
                      photo: grant.requirePhotoProof,
                      verified: grant.requireParentVerification,
                    )
                  : null,
            ),
            SwitchListTile(
              title: const Text('Requires parent approval'),
              value: grant.requiresParentApproval,
              onChanged: widget.isOwner
                  ? (v) => _patchRoleRow(
                      role: role,
                      capability: capability,
                      granted: grant.granted,
                      reqAp: v,
                      photo: grant.requirePhotoProof,
                      verified: grant.requireParentVerification,
                    )
                  : null,
            ),
            SwitchListTile(
              title: const Text('Chore photo proof'),
              subtitle: Text(
                'Only applies to ${Capability.choresCompleteTask.wireValue}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: grant.requirePhotoProof,
              onChanged:
                  widget.isOwner && capability == Capability.choresCompleteTask
                  ? (v) => _patchRoleRow(
                      role: role,
                      capability: capability,
                      granted: grant.granted,
                      reqAp: grant.requiresParentApproval,
                      photo: v,
                      verified: grant.requireParentVerification,
                    )
                  : null,
            ),
            SwitchListTile(
              title: const Text('Chore parent verification'),
              value: grant.requireParentVerification,
              onChanged:
                  widget.isOwner && capability == Capability.choresCompleteTask
                  ? (v) => _patchRoleRow(
                      role: role,
                      capability: capability,
                      granted: grant.granted,
                      reqAp: grant.requiresParentApproval,
                      photo: grant.requirePhotoProof,
                      verified: v,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
