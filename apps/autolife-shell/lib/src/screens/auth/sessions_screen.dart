import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

/// Session management + global sign-out (GoTrue scopes).
class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);

    Future<void> doLocal() async {
      final messenger = ScaffoldMessenger.maybeOf(context);
      final nav = Navigator.maybeOf(context);
      final ok = await ref.read(authServiceProvider).logoutCurrentSession();
      ok.when<void>(
        success: (_) {
          messenger?.showSnackBar(
            const SnackBar(content: Text('Signed out on this device.')),
          );
          nav?.maybePop();
        },
        failure: (f) => messenger?.showSnackBar(
          SnackBar(content: Text(f.message ?? 'Sign out failed')),
        ),
      );
    }

    Future<void> doGlobal() async {
      final messenger = ScaffoldMessenger.maybeOf(context);
      final ok = await ref.read(authServiceProvider).logoutAllDevices();
      ok.when<void>(
        success: (_) => messenger?.showSnackBar(
          const SnackBar(content: Text('Logged out everywhere.')),
        ),
        failure: (f) => messenger?.showSnackBar(
          SnackBar(content: Text(f.message ?? 'Global sign-out failed')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: StreamBuilder<AutoLifeAuthState>(
        stream: auth.authStates,
        initialData: auth.currentState,
        builder: (context, snap) {
          final state = snap.data ?? auth.currentState;
          final session = state.session;
          final user = state.user;
          final exp =
              session == null || session.accessTokenExpiresAtEpochSec == 0
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                  session.accessTokenExpiresAtEpochSec * 1000,
                  isUtc: true,
                );

          return ListView(
            padding: const EdgeInsets.all(AutoLifeSpacing.md),
            children: [
              AutoLifeSurfaceCard(
                child: Padding(
                  padding: const EdgeInsets.all(AutoLifeSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Signed-in account',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if ((user?.email ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(user!.email!),
                        ),
                      const SizedBox(height: AutoLifeSpacing.sm),
                      Text(
                        'Session claim: '
                        '${session?.sessionIdClaim ?? 'n/a'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (session != null &&
                          session.oauthProviderHints.isNotEmpty) ...[
                        const SizedBox(height: AutoLifeSpacing.xs),
                        Text(
                          'Linked providers: '
                          '${session.oauthProviderHints.join(', ')}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (exp != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AutoLifeSpacing.sm,
                          ),
                          child: Text(
                            'Access expiry (UTC): ${exp.toIso8601String()}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AutoLifeSpacing.sm),
              const ListTile(
                leading: Icon(Icons.smartphone_outlined),
                title: Text('Active device snapshot'),
                subtitle: Text(
                  'Scopes cover device-local vs cross-device revocation.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const Divider(),
              AutoLifeButton(
                label: 'Log out this device',
                variant: AutoLifeButtonVariant.secondary,
                onPressed: state.isSignedIn ? doLocal : null,
              ),
              const SizedBox(height: AutoLifeSpacing.sm),
              AutoLifeButton(
                label: 'Log out everywhere',
                variant: AutoLifeButtonVariant.destructive,
                icon: Icons.logout_outlined,
                onPressed: state.isSignedIn ? doGlobal : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
