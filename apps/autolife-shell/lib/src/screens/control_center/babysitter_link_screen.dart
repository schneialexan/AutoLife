import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/privacy_providers.dart';

/// Owner UI: mint and manage babysitter read links for the active family.
class BabysitterLinkScreen extends ConsumerStatefulWidget {
  const BabysitterLinkScreen({
    super.key,
    required this.familyId,
    required this.familyName,
  });

  final String familyId;
  final String familyName;

  @override
  ConsumerState<BabysitterLinkScreen> createState() =>
      _BabysitterLinkScreenState();
}

class _BabysitterLinkScreenState extends ConsumerState<BabysitterLinkScreen> {
  var _wifi = false;
  var _emergency = false;
  var _allergies = false;
  var _locations = false;
  var _busy = false;
  List<BabysitterLink>? _rows;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final svc = ref.read(babysitterLinkServiceProvider);
    final r = await svc.listLinks(familyId: widget.familyId);
    r.when(
      success: (list) {
        if (mounted) setState(() => _rows = list);
      },
      failure: (f) {
        if (mounted) {
          ScaffoldMessenger.maybeOf(
            context,
          )?.showSnackBar(SnackBar(content: Text(f.message ?? f.code)));
        }
      },
    );
  }

  Future<void> _create() async {
    setState(() => _busy = true);
    final svc = ref.read(babysitterLinkServiceProvider);
    final toggles = BabysitterScopeToggles(
      wifiCredentials: _wifi,
      emergencyContacts: _emergency,
      allergies: _allergies,
      locations: _locations,
    );
    final created = await svc.createLink(
      familyId: widget.familyId,
      toggles: toggles,
      label: 'shared',
    );
    if (!mounted) return;
    setState(() => _busy = false);
    created.when(
      success: (c) async {
        await _refresh();
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Link created'),
            content: SelectableText(
              c.rawToken,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: c.rawToken));
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Copy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      failure: (f) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(f.message ?? f.code)));
      },
    );
  }

  Future<void> _revoke(String id) async {
    final svc = ref.read(babysitterLinkServiceProvider);
    final r = await svc.revokeLink(linkId: id);
    r.when(
      success: (_) => _refresh(),
      failure: (f) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(f.message ?? f.code)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AutoLifeAppBar(
        title: Text('Babysitter link · ${widget.familyName}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AutoLifeSpacing.md),
        children: [
          Text(
            'Create a time-limited link (24 hours by default). Only the capabilities you enable are returned by '
            '`babysitter_scope` for recipients.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AutoLifeSpacing.md),
          SwitchListTile(
            title: const Text('WiFi credentials'),
            value: _wifi,
            onChanged: (v) => setState(() => _wifi = v),
          ),
          SwitchListTile(
            title: const Text('Emergency contacts'),
            value: _emergency,
            onChanged: (v) => setState(() => _emergency = v),
          ),
          SwitchListTile(
            title: const Text('Allergies'),
            value: _allergies,
            onChanged: (v) => setState(() => _allergies = v),
          ),
          SwitchListTile(
            title: const Text('Locations / addresses'),
            value: _locations,
            onChanged: (v) => setState(() => _locations = v),
          ),
          const SizedBox(height: AutoLifeSpacing.sm),
          FilledButton(
            onPressed: _busy ? null : _create,
            child: Text(_busy ? 'Working…' : 'Generate link'),
          ),
          const Divider(height: AutoLifeSpacing.xl),
          Text('Active links', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AutoLifeSpacing.sm),
          if (_rows == null)
            const Center(child: CircularProgressIndicator())
          else if (_rows!.isEmpty)
            Text('None yet.', style: Theme.of(context).textTheme.bodySmall)
          else
            ..._rows!.map(
              (l) => ListTile(
                title: Text(l.label.isEmpty ? l.id.substring(0, 8) : l.label),
                subtitle: Text(
                  'expires ${l.expiresAt.toLocal()} · '
                  '${l.revokedAt != null ? 'revoked' : 'active'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: l.revokedAt != null
                    ? null
                    : IconButton(
                        tooltip: 'Revoke',
                        icon: const Icon(Icons.block),
                        onPressed: () => _revoke(l.id),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
