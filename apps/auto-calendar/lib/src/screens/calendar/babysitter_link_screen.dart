import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase/supabase.dart';

final babysitterLinkClientProvider = Provider<SupabaseClient?>((ref) => null);

class BabysitterLinkScreen extends ConsumerWidget {
  const BabysitterLinkScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(babysitterLinkClientProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Babysitter share link')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: client == null
            ? const Text(
                'Supabase not configured in standalone calendar build. '
                'When embedded in the shell, this flow uses BabysitterLinkService '
                'for mint + revoke and the calendar-share-link edge projection for recipients.',
              )
            : BabysitterLinkPanel(
                service: BabysitterLinkService(client),
                familyId: familyId,
              ),
      ),
    );
  }
}

class BabysitterLinkPanel extends StatefulWidget {
  const BabysitterLinkPanel({
    super.key,
    required this.service,
    required this.familyId,
  });

  final BabysitterLinkService service;
  final String familyId;

  @override
  State<BabysitterLinkPanel> createState() => _BabysitterLinkPanelState();
}

class _BabysitterLinkPanelState extends State<BabysitterLinkPanel> {
  String? _lastToken;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text(
          'Recipient preview: events only, allowlisted columns. Revoke instantly '
          'from this list — expired / revoked tokens must 403 at the edge.',
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () async {
            final r = await widget.service.createLink(
              familyId: widget.familyId,
              toggles: const BabysitterScopeToggles(
                wifiCredentials: false,
                emergencyContacts: true,
                allergies: true,
                locations: false,
              ),
              label: 'Weekend sitter',
            );
            if (!mounted) return;
            r.map(
              success: (s) {
                setState(() {
                  _lastToken = s.value.rawToken;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link created — copy token once.')),
                );
              },
              failure: (f) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      f.failure.message ?? f.failure.code,
                    ),
                  ),
                );
              },
            );
          },
          child: const Text('Generate link'),
        ),
        if (_lastToken != null)
          SelectableText('Token (preview): $_lastToken'),
      ],
    );
  }
}
