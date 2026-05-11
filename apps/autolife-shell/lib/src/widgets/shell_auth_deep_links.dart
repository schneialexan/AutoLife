import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/tenancy_provider.dart';

/// Forwards OAuth + password-reset deep links into [AuthService.completeAuthRedirect].
///
/// Mounted above Material shell routes so Navigator snackbars resolve.
final class ShellAuthDeepLinks extends ConsumerStatefulWidget {
  const ShellAuthDeepLinks({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShellAuthDeepLinks> createState() => _ShellAuthDeepLinksState();
}

class _ShellAuthDeepLinksState extends ConsumerState<ShellAuthDeepLinks> {
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    unawaited(_activate());
  }

  Future<void> _activate() async {
    final appLinks = AppLinks();
    await _sub?.cancel();
    _sub = appLinks.uriLinkStream.listen(_handleUri, onError: (_) {});

    final initial = await appLinks.getInitialLink();
    if (initial != null) {
      await _handleUri(initial);
    }
  }

  Future<void> _handleUri(Uri uri) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (uri.scheme == 'autolife' && uri.host == 'invite') {
      final token = uri.queryParameters['token'];
      if (token != null && token.trim().isNotEmpty) {
        try {
          final tenancy = ref.read(tenancyServiceProvider);
          final res = await tenancy.acceptInvitation(token: token.trim());
          res.when<void>(
            success: (_) => messenger?.showSnackBar(
              const SnackBar(content: Text('Invitation accepted')),
            ),
            failure: (Failure f) => messenger?.showSnackBar(
              SnackBar(
                content: Text(f.message ?? 'Could not accept invitation'),
              ),
            ),
          );
        } catch (_) {
          messenger?.showSnackBar(
            const SnackBar(content: Text('Tenancy is not available yet.')),
          );
        }
        return;
      }
    }

    final svc = ref.read(authServiceProvider);
    final res = await svc.completeAuthRedirect(uri);
    res.when<void>(
      success: (_) {},
      failure: (Failure f) => messenger?.showSnackBar(
        SnackBar(
          content: Text(f.message ?? 'Could not complete auth callback.'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
