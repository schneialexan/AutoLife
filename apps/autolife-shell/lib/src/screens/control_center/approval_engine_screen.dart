import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/providers/shell_providers.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lists pending `approval_requests` and resolves them through [ApprovalEngine].
class ApprovalEngineScreen extends ConsumerStatefulWidget {
  const ApprovalEngineScreen({
    super.key,
    required this.familyId,
    required this.familyName,
    required this.canResolve,
  });

  final String familyId;
  final String familyName;
  final bool canResolve;

  @override
  ConsumerState<ApprovalEngineScreen> createState() =>
      _ApprovalEngineScreenState();
}

class _ApprovalEngineScreenState extends ConsumerState<ApprovalEngineScreen> {
  var _loading = false;
  var _error = '';
  List<Map<String, dynamic>> _pending = const [];

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
          .from('approval_requests')
          .select()
          .eq('family_id', widget.familyId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final list = <Map<String, dynamic>>[];
      for (final raw in data as List<dynamic>) {
        list.add(Map<String, dynamic>.from(raw as Map));
      }
      if (mounted) {
        setState(() {
          _pending = list;
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

  Future<void> _resolve(Map<String, dynamic> row, String status) async {
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) return;
    final engine = ApprovalEngine(
      eventProducer: ref.read(shellEventProducerProvider),
      defaultTenant: Tenant(tenantId: widget.familyId),
      actorProfileId: uid,
    );

    var snap = Map<String, dynamic>.from(row);
    final client = ref.read(supabaseClientProvider);
    Future<void> persist(Map<String, dynamic> merged) async {
      await client
          .from('approval_requests')
          .update({
            'status': merged['status'],
            'resolver_profile_id': merged['resolver_profile_id'],
            'applied_auto_rule_id': merged['applied_auto_rule_id'],
            'resolved_at': merged['resolved_at'],
            'updated_at': merged['updated_at'],
          })
          .eq('id', merged['id'] as String);
    }

    final res = await engine.transitionPending(
      rowSnapshot: snap,
      persist: persist,
      desiredStatus: status,
      resolverProfileId: uid,
    );

    if (!mounted) return;
    res.when(
      success: (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Moved to $status')));
        load();
      },
      failure: (f) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(f.message ?? f.code)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approvals · ${widget.familyName}'),
        actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh))],
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading && _pending.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AutoLifeSpacing.md),
          child: Text(
            _error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      );
    }
    if (_pending.isEmpty) {
      return const Center(child: Text('No pending approval requests.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AutoLifeSpacing.md),
      itemCount: _pending.length,
      separatorBuilder: (context, ignored) =>
          const SizedBox(height: AutoLifeSpacing.sm),
      itemBuilder: (context, i) {
        final row = _pending[i];
        final cap = row['capability'] as String? ?? '';
        final exp = row['expires_at'] as String? ?? '';
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AutoLifeSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cap, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  'Expires: $exp',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (widget.canResolve) ...[
                  const SizedBox(height: AutoLifeSpacing.sm),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: () => _resolve(row, 'approved'),
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: AutoLifeSpacing.sm),
                      OutlinedButton(
                        onPressed: () => _resolve(row, 'rejected'),
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
