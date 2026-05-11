import 'dart:async';

import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/providers/shell_providers.dart';
import 'package:autolife_shell/src/providers/tenancy_provider.dart';
import 'package:autolife_shell/src/screens/onboarding/create_family_screen.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// After sign-in: blocks the shell on tenancy load, routes to create-family when needed.
final class TenancyBootstrapShell extends ConsumerStatefulWidget {
  const TenancyBootstrapShell({super.key, required this.dashboard});

  /// Main shell subtree (navigation, smoke surfaces, …).
  final Widget Function({
    required List<TenancyEnrollment> enrollments,
    required String activeFamilyId,
    required VoidCallback reloadTenancy,
  })
  dashboard;

  @override
  ConsumerState<TenancyBootstrapShell> createState() =>
      _TenancyBootstrapShellState();
}

class _TenancyBootstrapShellState extends ConsumerState<TenancyBootstrapShell> {
  var _busy = true;
  Object? _error;
  List<TenancyEnrollment> _enrollments = const [];
  String? _activeFamilyId;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> reload() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    await _load();
  }

  Future<void> _load() async {
    final tenancy = ref.read(tenancyServiceProvider);
    final uid = tenancy.currentUserId;
    if (uid == null) {
      if (mounted) {
        setState(() {
          _busy = false;
          _enrollments = const [];
        });
      }
      return;
    }

    ref.read(syncEngineProvider).setProfilePullScope(uid);

    final listRes = await tenancy.listMyActiveEnrollments();
    if (!mounted) return;

    await listRes.when(
      failure: (f) async {
        setState(() {
          _busy = false;
          _error = f;
        });
      },
      success: (list) async {
        String? active;
        try {
          final row = await ref
              .read(supabaseClientProvider)
              .from('profile')
              .select('active_family_id')
              .eq('id', uid)
              .maybeSingle();
          active = row?['active_family_id'] as String?;
        } catch (_) {
          active = null;
        }

        if (active == null && list.isNotEmpty) {
          active = list.first.family.id;
          final _ = await tenancy.switchActiveFamily(familyId: active);
        } else if (active != null) {
          final known = list.any((e) => e.family.id == active);
          if (!known && list.isNotEmpty) {
            active = list.first.family.id;
            final _ = await tenancy.switchActiveFamily(familyId: active);
          }
        }

        final engine = ref.read(syncEngineProvider);
        engine.setFamilyPullScope(active);

        if (!mounted) return;
        setState(() {
          _busy = false;
          _error = null;
          _enrollments = list;
          _activeFamilyId = active;
        });
        unawaited(engine.runCycle());
      },
    );
  }

  Future<void> _afterFamilyCreated() => reload();

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      final msg = _error is Failure
          ? (_error! as Failure).message ?? '$_error'
          : '$_error';
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AutoLifeSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg, textAlign: TextAlign.center),
                const SizedBox(height: AutoLifeSpacing.md),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _busy = true;
                      _error = null;
                    });
                    unawaited(_load());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_enrollments.isEmpty) {
      return CreateFamilyScreen(onFamilyCreated: _afterFamilyCreated);
    }

    final active =
        _activeFamilyId ??
        (_enrollments.isNotEmpty ? _enrollments.first.family.id : '');

    return widget.dashboard(
      enrollments: _enrollments,
      activeFamilyId: active,
      reloadTenancy: reload,
    );
  }
}
