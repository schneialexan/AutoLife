import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';

import '../common/failure.dart';
import '../common/result.dart';
import 'capability.dart';
import 'capability_grant_defaults.dart';
import 'role.dart';

/// Loads effective [CapabilityGrantDefaults] for `(familyId, role, capability)`.
///
/// SQLite / offline paths can omit [familyId] fidelity and fall back to [defaultsFor].
abstract class CapabilityGrantSource {
  Future<CapabilityGrantDefaults?> lookup({
    required String familyId,
    required FamilyRole role,
    required Capability capability,
  });
}

/// Offline-friendly source: ignores family and mirrors YAML defaults.
final class YamlDefaultsCapabilityGrantSource implements CapabilityGrantSource {
  const YamlDefaultsCapabilityGrantSource();

  @override
  Future<CapabilityGrantDefaults?> lookup({
    required String familyId,
    required FamilyRole role,
    required Capability capability,
  }) async => defaultsFor(role, capability);
}

/// Reads `capability_grants`; falls back to YAML defaults when a row is missing.
final class SupabaseCapabilityGrantSource implements CapabilityGrantSource {
  SupabaseCapabilityGrantSource(this._client);

  final SupabaseClient _client;

  @override
  Future<CapabilityGrantDefaults?> lookup({
    required String familyId,
    required FamilyRole role,
    required Capability capability,
  }) async {
    final row = await _client
        .from('capability_grants')
        .select(
          'granted,requires_parent_approval,require_photo_proof,'
          'require_parent_verification',
        )
        .eq('family_id', familyId)
        .eq('role', role.name)
        .eq('capability', capability.wireValue)
        .maybeSingle();
    if (row == null) {
      return defaultsFor(role, capability);
    }
    final map = Map<String, dynamic>.from(row);
    return CapabilityGrantDefaults(
      granted: map['granted'] as bool,
      requiresParentApproval: map['requires_parent_approval'] as bool,
      requirePhotoProof: map['require_photo_proof'] as bool,
      requireParentVerification: map['require_parent_verification'] as bool,
    );
  }
}

/// Capability / chore policy façade used by modules and Phase 2.3 shells.
final class RolePolicyService {
  RolePolicyService(this._source);

  final CapabilityGrantSource _source;

  Future<Result<CapabilityGrantDefaults>> resolvedGrant({
    required String familyId,
    required FamilyRole role,
    required Capability capability,
  }) async {
    try {
      final raw = await _source.lookup(
        familyId: familyId,
        role: role,
        capability: capability,
      );
      if (raw == null) {
        return Result.failure(const Failure(code: 'capability_grant_missing'));
      }
      return Result.success(raw);
    } catch (e, st) {
      return Result.failure(
        Failure(
          code: 'capability_grant_lookup_failed',
          message: '$e',
          details: {'stack': st.toString()},
        ),
      );
    }
  }

  Future<Result<bool>> userMayUseCapability({
    required String familyId,
    required FamilyRole role,
    required Capability capability,
  }) async {
    final g = await resolvedGrant(
      familyId: familyId,
      role: role,
      capability: capability,
    );
    return g.when(
      success: (grant) => Result.success(grant.granted),
      failure: (f) => Result.failure(f),
    );
  }
}

@immutable
final class CapabilityUpdate {
  const CapabilityUpdate({
    required this.familyId,
    required this.role,
    required this.capability,
    required this.granted,
    required this.requiresParentApproval,
    required this.requirePhotoProof,
    required this.requireParentVerification,
  });

  final String familyId;
  final FamilyRole role;
  final Capability capability;
  final bool granted;
  final bool requiresParentApproval;
  final bool requirePhotoProof;
  final bool requireParentVerification;

  Map<String, dynamic> toSupabasePatch() => {
    'family_id': familyId,
    'role': role.name,
    'capability': capability.wireValue,
    'granted': granted,
    'requires_parent_approval': requiresParentApproval,
    'require_photo_proof': requirePhotoProof,
    'require_parent_verification': requireParentVerification,
    'updated_at': DateTime.now().toUtc().toIso8601String(),
  };
}

Future<Result<void>> persistCapabilityGrantPatch({
  required SupabaseClient client,
  required CapabilityUpdate patch,
}) async {
  try {
    await client.from('capability_grants').upsert(patch.toSupabasePatch());
    return const Result.success(null);
  } on PostgrestException catch (e) {
    return Result.failure(
      Failure(code: 'capability_patch_failed', message: e.message),
    );
  } catch (e) {
    return Result.failure(
      Failure(code: 'capability_patch_failed', message: '$e'),
    );
  }
}
