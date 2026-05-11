import 'package:supabase/supabase.dart';

import '../common/failure.dart';
import '../common/result.dart';
import '../policy/role.dart';
import 'models/family.dart';
import 'models/family_invitation.dart';
import 'models/membership.dart';
import 'tenancy_service.dart';

/// Supabase/PostgREST implementation of [TenancyService].
final class SupabaseTenancyService implements TenancyService {
  SupabaseTenancyService(this._client);

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentSession?.user.id;

  @override
  Future<Result<TenancyEnrollment>> createFamily({required String name}) async {
    final uid = currentUserId;
    if (uid == null) {
      return Result.failure(
        Failure(code: 'auth_required', message: 'Sign in required'),
      );
    }
    try {
      final familyRow = await _client
          .from('families')
          .insert({'name': name.trim(), 'created_by': uid})
          .select()
          .single();

      await _client.from('memberships').insert({
        'family_id': familyRow['id'] as String,
        'user_id': uid,
        'role': FamilyRole.owner.name,
      });

      await _client
          .from('profile')
          .update({'active_family_id': familyRow['id'] as String})
          .eq('id', uid);

      final membership = Membership(
        familyId: familyRow['id'] as String,
        userId: uid,
        role: FamilyRole.owner,
        joinedAt: DateTime.now().toUtc(),
        removedAt: null,
        updatedAt: DateTime.now().toUtc(),
      );

      final family = Family.fromJson(Map<String, dynamic>.from(familyRow));
      return Result.success(
        TenancyEnrollment(membership: membership, family: family),
      );
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: 'create_family_failed', message: e.message),
      );
    } catch (e) {
      return Result.failure(
        Failure(code: 'create_family_failed', message: '$e'),
      );
    }
  }

  @override
  Future<Result<void>> switchActiveFamily({required String familyId}) async {
    final uid = currentUserId;
    if (uid == null) {
      return Result.failure(
        Failure(code: 'auth_required', message: 'Sign in required'),
      );
    }
    try {
      final check = await _client
          .from('memberships')
          .select('family_id')
          .eq('family_id', familyId)
          .eq('user_id', uid)
          .isFilter('removed_at', null)
          .maybeSingle();
      if (check == null) {
        return Result.failure(
          Failure(
            code: 'not_family_member',
            message: 'Not an active member of this family.',
          ),
        );
      }
      await _client
          .from('profile')
          .update({'active_family_id': familyId})
          .eq('id', uid);
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: 'switch_family_failed', message: e.message),
      );
    } catch (e) {
      return Result.failure(
        Failure(code: 'switch_family_failed', message: '$e'),
      );
    }
  }

  @override
  Future<Result<List<TenancyEnrollment>>> listMyActiveEnrollments() async {
    final uid = currentUserId;
    if (uid == null) {
      return Result.failure(
        Failure(code: 'auth_required', message: 'Sign in required'),
      );
    }
    try {
      final rows = await _client
          .from('memberships')
          .select('*, families(*)')
          .eq('user_id', uid)
          .isFilter('removed_at', null);

      final list = (rows as List<dynamic>).map<TenancyEnrollment>((raw) {
        final row = Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);
        final famRaw = row['families'];
        Map<String, dynamic> famJson;
        if (famRaw is Map) {
          famJson = Map<String, dynamic>.from(famRaw);
        } else {
          throw StateError('missing_families_embed');
        }
        row.remove('families');
        return TenancyEnrollment(
          membership: Membership.fromJson(row),
          family: Family.fromJson(famJson),
        );
      }).toList();

      list.sort((a, b) => a.family.name.compareTo(b.family.name));
      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: 'list_memberships_failed', message: e.message),
      );
    } catch (e) {
      return Result.failure(
        Failure(code: 'list_memberships_failed', message: '$e'),
      );
    }
  }

  @override
  Future<Result<void>> leaveFamily({required String familyId}) async {
    final uid = currentUserId;
    if (uid == null) {
      return Result.failure(
        Failure(code: 'auth_required', message: 'Sign in required'),
      );
    }
    try {
      await _client
          .from('memberships')
          .update({'removed_at': DateTime.now().toUtc().toIso8601String()})
          .eq('family_id', familyId)
          .eq('user_id', uid);

      final profile = await _client
          .from('profile')
          .select('active_family_id')
          .eq('id', uid)
          .maybeSingle();

      final active = profile == null
          ? null
          : profile['active_family_id'] as String?;
      if (active == familyId) {
        final next = await _client
            .from('memberships')
            .select('family_id')
            .eq('user_id', uid)
            .isFilter('removed_at', null)
            .limit(1)
            .maybeSingle();
        await _client
            .from('profile')
            .update({
              'active_family_id': next == null ? null : next['family_id'],
            })
            .eq('id', uid);
      }

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: 'leave_family_failed', message: e.message),
      );
    } catch (e) {
      return Result.failure(
        Failure(code: 'leave_family_failed', message: '$e'),
      );
    }
  }

  @override
  Future<Result<void>> removeMember({
    required String familyId,
    required String userId,
  }) async {
    try {
      await _client.rpc<void>(
        'remove_family_membership',
        params: {'p_family_id': familyId, 'p_user_id': userId},
      );
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: 'remove_member_failed', message: e.message),
      );
    } catch (e) {
      return Result.failure(
        Failure(code: 'remove_member_failed', message: '$e'),
      );
    }
  }

  @override
  Future<Result<FamilyInvitation>> sendInvitation({
    required String familyId,
    required String email,
    String invitedRole = 'partner',
  }) async {
    try {
      final res = await _client.functions.invoke(
        'send-invitation',
        body: <String, dynamic>{
          'family_id': familyId,
          'email': email.trim().toLowerCase(),
          'invited_role': invitedRole,
        },
      );
      if (res.status != 200 || res.data == null) {
        return Result.failure(
          Failure(
            code: 'invite_edge_failed',
            message: '${res.status}: ${res.data}',
          ),
        );
      }
      final map = Map<String, dynamic>.from(res.data! as Map<dynamic, dynamic>);
      final invMap = Map<String, dynamic>.from(
        map['invitation'] as Map<dynamic, dynamic>,
      );
      return Result.success(FamilyInvitation.fromJson(invMap));
    } catch (e) {
      return Result.failure(Failure(code: 'invite_failed', message: '$e'));
    }
  }

  @override
  Future<Result<List<FamilyInvitation>>> listPendingInvitationsForFamily({
    required String familyId,
  }) async {
    try {
      final rows = await _client
          .from('family_invitations')
          .select()
          .eq('family_id', familyId)
          .isFilter('accepted_at', null)
          .isFilter('revoked_at', null)
          .order('created_at', ascending: false);

      final list = (rows as List<dynamic>)
          .map(
            (e) => FamilyInvitation.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ),
          )
          .toList();
      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: 'list_invites_failed', message: e.message),
      );
    } catch (e) {
      return Result.failure(
        Failure(code: 'list_invites_failed', message: '$e'),
      );
    }
  }

  @override
  Future<Result<List<FamilyInvitation>>>
  listOpenInvitationsForCurrentUser() async {
    if (currentUserId == null) {
      return Result.failure(
        Failure(code: 'auth_required', message: 'Sign in required'),
      );
    }
    try {
      final rows = await _client
          .from('family_invitations')
          .select()
          .isFilter('accepted_at', null)
          .isFilter('revoked_at', null)
          .gt('expires_at', DateTime.now().toUtc().toIso8601String())
          .order('expires_at');

      final list = (rows as List<dynamic>)
          .map(
            (e) => FamilyInvitation.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ),
          )
          .toList();
      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: 'list_my_invites_failed', message: e.message),
      );
    } catch (e) {
      return Result.failure(
        Failure(code: 'list_my_invites_failed', message: '$e'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> acceptInvitation({
    required String token,
  }) async {
    try {
      final data = await _client.rpc<Map<String, dynamic>?>(
        'accept_invitation',
        params: {'token': token},
      );
      if (data == null) {
        return Result.failure(const Failure(code: 'accept_failed'));
      }
      return Result.success(Map<String, dynamic>.from(data));
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: mapInvitePostgresCode(e.code), message: e.message),
      );
    } catch (e) {
      return Result.failure(Failure(code: 'accept_failed', message: '$e'));
    }
  }

  @override
  Future<Result<void>> revokeInvitation({required String invitationId}) async {
    try {
      await _client.rpc<void>(
        'revoke_invitation',
        params: {'invitation_id': invitationId},
      );
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: mapInvitePostgresCode(e.code), message: e.message),
      );
    } catch (e) {
      return Result.failure(Failure(code: 'revoke_failed', message: '$e'));
    }
  }
}

/// Maps Postgres RAISE `errcode` / PostgREST code strings to readable failure ids.
String mapInvitePostgresCode(Object? code) {
  final raw = '$code'.toUpperCase();
  if (raw.contains('P0001')) {
    return 'invitation_logic_error';
  }
  return 'rpc_failed';
}
