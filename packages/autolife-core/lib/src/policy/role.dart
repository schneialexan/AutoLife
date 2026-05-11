/// Mirrors Postgres `family_role` (Phase 2.3).
enum FamilyRole {
  owner,
  partner,
  child,
  teenager,
  grandparent,
  guest,
  babysitter,
}

/// Parses wire values produced by Postgres / PostgREST (snake_case names).
extension FamilyRoleWire on FamilyRole {
  static FamilyRole parseWire(String raw) {
    final k = raw.trim().toLowerCase();
    return FamilyRole.values.firstWhere(
      (e) => e.name == k,
      orElse: () {
        switch (k) {
          case 'member':
          case 'admin':
            return FamilyRole.partner;
          default:
            return FamilyRole.guest;
        }
      },
    );
  }
}
