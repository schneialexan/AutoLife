import 'package:autolife_platform/autolife_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, StorageException;

/// Compact chip reflecting the live [SyncStatus]. Safe to use even in local-only
/// builds (shows "Local only").
class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = ref
        .watch(syncStatusProvider)
        .maybeWhen(data: (s) => s, orElse: () => SyncStatus.localOnly);

    final (IconData icon, Color color) = switch (status) {
      SyncStatus.synced => (Icons.cloud_done_outlined, Colors.green),
      SyncStatus.syncing => (
        Icons.cloud_sync_outlined,
        theme.colorScheme.primary,
      ),
      SyncStatus.offline => (
        Icons.cloud_off_outlined,
        theme.colorScheme.outline,
      ),
      SyncStatus.localOnly => (
        Icons.phone_android_outlined,
        theme.colorScheme.outline,
      ),
      SyncStatus.error => (Icons.error_outline, theme.colorScheme.error),
    };

    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(status.label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// Sync section: sign in / create account, optional device pairing,
/// claim-local-vault, and sign out. Local data is never deleted here.
class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _run(
    Future<void> Function() action,
    String successMessage, {
    IconData successIcon = Icons.check_circle_outline,
  }) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) {
        _showResult(successMessage, icon: successIcon);
      }
    } catch (error) {
      if (mounted) {
        _showResult(_friendlyError(error), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  /// Runs a full push+pull and reports the real outcome, including the offline
  /// case (which [SyncCoordinator.syncNow] reflects in status rather than
  /// throwing) so the user never sees a false "Sync complete".
  Future<void> _syncNow(AutolifePlatform platform) async {
    setState(() => _busy = true);
    try {
      await platform.coordinator.syncNow();
      if (!mounted) {
        return;
      }
      if (platform.coordinator.status.value == SyncStatus.offline) {
        _showResult(
          'You are offline — your changes will sync when you reconnect.',
          icon: Icons.cloud_off_outlined,
        );
      } else {
        _showResult('Everything is up to date', icon: Icons.cloud_done_outlined);
      }
    } catch (error) {
      if (mounted) {
        _showResult(_friendlyError(error), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  /// Maps low-level sync failures to a short, human message the user can act on.
  String _friendlyError(Object error) {
    if (error is AuthException) {
      return error.message;
    }
    if (error is PostgrestException) {
      final code = error.code ?? '';
      final message = error.message.toLowerCase();
      if (code == '406' ||
          code == 'PGRST106' ||
          message.contains('schema must be one of')) {
        return 'Sync is not fully set up on the server: the "assets" data '
            'schema is not exposed to the API. Apply the latest Supabase '
            'migration (0005) and try again.';
      }
      if (code == '42501' || message.contains('row-level security')) {
        return 'The server rejected this change (row-level security). Make '
            'sure you are signed in to the correct account.';
      }
      return 'Sync failed: ${error.message}';
    }
    if (error is StorageException) {
      return 'A file could not be uploaded: ${error.message}';
    }
    return 'Something went wrong. Please try again.';
  }

  void _showResult(String message, {bool isError = false, IconData? icon}) {
    final scheme = Theme.of(context).colorScheme;
    final background = isError
        ? scheme.errorContainer
        : scheme.secondaryContainer;
    final foreground = isError
        ? scheme.onErrorContainer
        : scheme.onSecondaryContainer;
    final leadingIcon =
        icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline);

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: background,
        duration: Duration(seconds: isError ? 6 : 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(leadingIcon, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: foreground)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platform = ref.watch(autolifePlatformProvider);
    final authState = ref
        .watch(authStateProvider)
        .maybeWhen(data: (s) => s, orElse: () => platform.auth.state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: SyncStatusChip()),
          ),
        ],
      ),
      body: !platform.isSyncConfigured
          ? _buildNotConfigured(context)
          : authState == PlatformAuthState.authenticated
          ? _buildSignedIn(context, platform)
          : _buildSignedOut(context, platform),
    );
  }

  Widget _buildNotConfigured(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Sync is not enabled in this build',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your data is stored locally on this device. A build configured '
            'with a Supabase backend can sign in to sync across devices.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSignedOut(BuildContext context, AutolifePlatform platform) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Sign in to mirror your vault to your account and access it on '
          'another device. Your local data stays on this device either way.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _busy ? null : () => _signIn(platform),
          icon: const Icon(Icons.login),
          label: const Text('Sign in'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy ? null : () => _signUp(platform),
          icon: const Icon(Icons.person_add_alt),
          label: const Text('Create account'),
        ),
        const Divider(height: 40),
        Text('Have a pairing code?', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          'Enter a code from another signed-in device. Local items merge with '
          'the cloud using last-write-wins.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _busy ? null : () => _enterPairingCode(platform),
          icon: const Icon(Icons.qr_code_2),
          label: const Text('Enter pairing code'),
        ),
      ],
    );
  }

  Widget _buildSignedIn(BuildContext context, AutolifePlatform platform) {
    final theme = Theme.of(context);
    final userId = platform.auth.userId;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Signed in'),
            subtitle: Text(userId == null ? 'Synced account' : 'ID: $userId'),
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text('Sync now'),
          subtitle: const Text('Push pending changes and pull updates'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _busy ? null : () => _syncNow(platform),
        ),
        ListTile(
          leading: const Icon(Icons.cloud_upload_outlined),
          title: const Text('Back up local items'),
          subtitle: const Text(
            'Upload everything on this device to your account',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _busy
              ? null
              : () => _run(
                  platform.coordinator.claimLocalVault,
                  'Local items backed up',
                  successIcon: Icons.cloud_upload_outlined,
                ),
        ),
        ListTile(
          leading: const Icon(Icons.devices_other_outlined),
          title: const Text('Link another device'),
          subtitle: const Text('Show a one-time pairing code'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _busy ? null : () => _linkDevice(platform),
        ),
        const Divider(height: 32),
        ListTile(
          leading: Icon(Icons.logout, color: theme.colorScheme.error),
          title: Text(
            'Sign out',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          subtitle: const Text('Stops sync; keeps all local data'),
          onTap: _busy ? null : () => _run(platform.auth.signOut, 'Signed out'),
        ),
      ],
    );
  }

  Future<void> _signIn(AutolifePlatform platform) {
    return _run(
      () => platform.auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
      'Signed in',
    );
  }

  Future<void> _signUp(AutolifePlatform platform) {
    return _run(
      () => platform.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
      'Account created — check your email if confirmation is required',
    );
  }

  Future<void> _linkDevice(AutolifePlatform platform) async {
    setState(() => _busy = true);
    try {
      final code = await platform.auth.startDevicePairing();
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Pairing code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                code.code,
                style: Theme.of(ctx).textTheme.displaySmall?.copyWith(
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter this code on the other device under Sync → Enter '
                'pairing code. It is single-use and expires shortly.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) {
        _showResult(_friendlyError(error), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _enterPairingCode(AutolifePlatform platform) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter pairing code'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Code',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Pair'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (code == null || code.isEmpty) {
      return;
    }
    await _run(
      () => platform.auth.completeDevicePairing(code),
      'Device paired',
    );
  }
}
