/// Canonical Postgres enum `public.sensitivity_tier` (Phase 2.5).
enum SensitivityTier {
  publicFamily('public_family'),
  privateMember('private_member'),
  healthLocked('health_locked'),
  financeLocked('finance_locked');

  const SensitivityTier(this.wire);

  final String wire;

  static SensitivityTier? tryParse(String? raw) {
    if (raw == null) return null;
    for (final t in SensitivityTier.values) {
      if (t.wire == raw) return t;
    }
    return null;
  }
}
