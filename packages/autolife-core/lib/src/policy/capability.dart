import 'capability_grant_defaults.dart';
import 'capability_matrix_generated.dart';
import 'matrix_model.dart';
import 'role.dart';

/// Feature gate identifier (stored as dotted string in Postgres).
enum Capability {
  allowanceManage('allowance.manage'),
  allowanceView('allowance.view'),
  calendarCreateEvent('calendar.create_event'),
  calendarEditOwnEvent('calendar.edit_own_event'),
  calendarView('calendar.view'),
  choresCompleteTask('chores.complete_task'),
  choresManageAssignments('chores.manage_assignments'),
  choresViewAssigned('chores.view_assigned'),
  dashboardCustomizeFamilyDefault('dashboard.customize_family_default'),
  dashboardCustomizeOwn('dashboard.customize_own'),
  familyInviteMembers('family.invite_members'),
  familyManagePolicy('family.manage_policy'),
  familyViewMembers('family.view_members');

  const Capability(this.wireValue);

  /// Value written to `capability_grants.capability`, `approval_requests.capability`.
  final String wireValue;

  static Capability parse(String raw) =>
      Capability.values.firstWhere((c) => c.wireValue == raw);

  static Capability? tryParse(String raw) {
    try {
      return parse(raw);
    } on StateError {
      return null;
    }
  }
}

CapabilityGrantDefaults defaultsFor(FamilyRole role, Capability capability) {
  final m = kGeneratedCapabilityLookup[capability.wireValue]?[role.name];
  if (m == null) {
    return const CapabilityGrantDefaults(
      granted: false,
      requiresParentApproval: false,
      requirePhotoProof: false,
      requireParentVerification: false,
    );
  }
  return m;
}

ParsedPolicyMatrix loadPolicyMatrixFromYaml(String yamlSource) =>
    parsePolicyMatrixYaml(yamlSource);
