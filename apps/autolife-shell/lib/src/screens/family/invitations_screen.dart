import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/providers/tenancy_provider.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvitationsScreen extends ConsumerStatefulWidget {
  const InvitationsScreen({
    super.key,
    required this.familyId,
    required this.familyName,
    required this.reloadTenancy,
  });

  final String familyId;
  final String familyName;
  final VoidCallback reloadTenancy;

  @override
  ConsumerState<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends ConsumerState<InvitationsScreen> {
  final _email = TextEditingController();
  var _inviteBusy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _acceptTokenDialog() async {
    final ctrl = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Accept invitation'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Paste invite token'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
    if (raw == null || raw.isEmpty || !mounted) return;
    final tenancy = ref.read(tenancyServiceProvider);
    final res = await tenancy.acceptInvitation(token: raw);
    if (!mounted) return;
    res.when<void>(
      success: (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invitation accepted')));
        widget.reloadTenancy();
        Navigator.of(context).pop();
      },
      failure: (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.message ?? 'Accept failed'))),
    );
  }

  Future<void> _invite() async {
    if (_inviteBusy || _email.text.trim().isEmpty) return;
    setState(() => _inviteBusy = true);
    final tenancy = ref.read(tenancyServiceProvider);
    final res = await tenancy.sendInvitation(
      familyId: widget.familyId,
      email: _email.text.trim(),
    );
    if (!mounted) return;
    setState(() => _inviteBusy = false);
    res.when<void>(
      success: (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invitation sent')));
        _email.clear();
      },
      failure: (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.message ?? 'Invite failed'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Invitations · ${widget.familyName}'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Your invites'),
              Tab(text: 'Family pending'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _IncomingTab(onAcceptTap: _acceptTokenDialog),
            _OutgoingTab(
              familyId: widget.familyId,
              emailController: _email,
              onInvite: _invite,
              inviteBusy: _inviteBusy,
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomingTab extends ConsumerStatefulWidget {
  const _IncomingTab({required this.onAcceptTap});

  final VoidCallback onAcceptTap;

  @override
  ConsumerState<_IncomingTab> createState() => _IncomingTabState();
}

class _IncomingTabState extends ConsumerState<_IncomingTab> {
  Object? _err;
  List<FamilyInvitation> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tenancy = ref.read(tenancyServiceProvider);
    final res = await tenancy.listOpenInvitationsForCurrentUser();
    if (!mounted) return;
    res.when<void>(
      failure: (f) => setState(() => _err = f.message ?? f.code),
      success: (list) => setState(() {
        _items = list;
        _err = null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_err != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(AutoLifeSpacing.md),
            child: Text('$_err', textAlign: TextAlign.center),
          ),
          FilledButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AutoLifeSpacing.md),
          child: FilledButton.icon(
            onPressed: widget.onAcceptTap,
            icon: const Icon(Icons.link),
            label: const Text('Enter token from email'),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final inv = _items[i];
              return ListTile(
                title: Text(inv.email),
                subtitle: Text('Expires ${inv.expiresAt.toLocal()}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OutgoingTab extends ConsumerStatefulWidget {
  const _OutgoingTab({
    required this.familyId,
    required this.emailController,
    required this.onInvite,
    required this.inviteBusy,
  });

  final String familyId;
  final TextEditingController emailController;
  final VoidCallback onInvite;
  final bool inviteBusy;

  @override
  ConsumerState<_OutgoingTab> createState() => _OutgoingTabState();
}

class _OutgoingTabState extends ConsumerState<_OutgoingTab> {
  Object? _err;
  List<FamilyInvitation> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tenancy = ref.read(tenancyServiceProvider);
    final res = await tenancy.listPendingInvitationsForFamily(
      familyId: widget.familyId,
    );
    if (!mounted) return;
    res.when<void>(
      failure: (f) => setState(() => _err = f.message ?? f.code),
      success: (list) => setState(() {
        _items = list;
        _err = null;
      }),
    );
  }

  Future<void> _revoke(String id) async {
    final tenancy = ref.read(tenancyServiceProvider);
    final res = await tenancy.revokeInvitation(invitationId: id);
    if (!mounted) return;
    res.when<void>(
      success: (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invitation revoked')));
        _load();
      },
      failure: (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.message ?? 'Revoke failed'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AutoLifeSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AutoLifeSpacing.sm),
              FilledButton(
                onPressed:
                    widget.inviteBusy ||
                        widget.emailController.text.trim().isEmpty
                    ? null
                    : widget.onInvite,
                child: Text(widget.inviteBusy ? 'Sending…' : 'Send invitation'),
              ),
            ],
          ),
        ),
        if (_err != null)
          Expanded(child: Center(child: Text('$_err')))
        else
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final inv = _items[i];
                return ListTile(
                  title: Text(inv.email),
                  subtitle: Text('expires ${inv.expiresAt.toLocal()}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    onPressed: () => _revoke(inv.id),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
