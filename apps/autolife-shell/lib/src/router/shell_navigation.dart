import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';

import '../screens/control_center/approval_engine_screen.dart';
import '../screens/control_center/babysitter_link_screen.dart';
import '../screens/control_center/biometric_locks_screen.dart';
import '../screens/control_center/role_matrix_screen.dart';
import '../screens/family/family_switcher_screen.dart';
import '../screens/family/invitations_screen.dart';
import '../screens/health/health_stub_screen.dart';
import '../shell/shell_workspace_data.dart';

/// Navigator helpers from shell chrome / settings (phase 3.1).
extension ShellWorkspaceNavigation on BuildContext {
  Future<void> openFamilySwitcher(ShellWorkspaceData ws) {
    if (ws.activeFamilyId.isEmpty) return Future.value();
    return Navigator.of(this).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FamilySwitcherScreen(
          enrollments: ws.enrollments,
          activeFamilyId: ws.activeFamilyId,
          reloadTenancy: ws.reloadTenancy,
        ),
      ),
    );
  }

  Future<void> openInvitations(ShellWorkspaceData ws, String title) {
    if (ws.activeFamilyId.isEmpty) return Future.value();
    return Navigator.of(this).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => InvitationsScreen(
          familyId: ws.activeFamilyId,
          familyName: title,
          reloadTenancy: ws.reloadTenancy,
        ),
      ),
    );
  }

  Future<void> openRoleMatrix(ShellWorkspaceData ws, String title, bool owner) {
    return Navigator.of(this).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RoleMatrixScreen(
          familyId: ws.activeFamilyId,
          familyName: title,
          isOwner: owner,
        ),
      ),
    );
  }

  Future<void> openApprovalQueue(
    ShellWorkspaceData ws,
    String title,
    bool canResolve,
  ) {
    return Navigator.of(this).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ApprovalEngineScreen(
          familyId: ws.activeFamilyId,
          familyName: title,
          canResolve: canResolve,
        ),
      ),
    );
  }

  Future<void> openBiometricLocks() {
    return Navigator.of(this).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const BiometricLocksScreen(),
      ),
    );
  }

  Future<void> openBabysitterLink(ShellWorkspaceData ws, String title) {
    return Navigator.of(this).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BabysitterLinkScreen(
          familyId: ws.activeFamilyId,
          familyName: title,
        ),
      ),
    );
  }

  Future<void> openHealthDemo() {
    return Navigator.of(this).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const HealthStubScreen(),
      ),
    );
  }

  Future<void> silentRefreshProbe(AuthService svc) async {
    final nav = ScaffoldMessenger.maybeOf(this);
    final res = await svc.refreshSessionExplicit();
    res.when<void>(
      success: (_) => nav?.showSnackBar(
        const SnackBar(content: Text('Refresh completed gracefully.')),
      ),
      failure: (Failure fail) => nav?.showSnackBar(
        SnackBar(content: Text(fail.message ?? 'Refresh failed')),
      ),
    );
  }
}
