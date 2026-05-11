import 'package:supabase/supabase.dart';

import '../common/failure.dart';
import '../common/result.dart';
import 'babysitter_link_crypto.dart';
import 'models/babysitter_link.dart';
import 'models/babysitter_scope_toggles.dart';

/// Owner lifecycle + token introspection for `public.babysitter_links`.
final class BabysitterLinkService {
  BabysitterLinkService(this._client);

  final SupabaseClient _client;

  static const defaultTtl = Duration(hours: 24);

  /// Creates a link; [rawToken] is returned once for sharing (store only hash server-side).
  Future<Result<CreatedBabysitterLink>> createLink({
    required String familyId,
    required BabysitterScopeToggles toggles,
    String label = '',
    DateTime? expiresAt,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      return Result.failure(
        Failure(code: 'auth_required', message: 'Sign in required'),
      );
    }
    final raw = generateBabysitterRawToken();
    final hash = babysitterTokenSha256Hex(raw);
    final exp = expiresAt ?? DateTime.now().toUtc().add(defaultTtl);
    try {
      final row = await _client
          .from('babysitter_links')
          .insert({
            'family_id': familyId,
            'token_hash': hash,
            'label': label,
            ...toggles.toInsertRow(),
            'created_by': uid,
            'expires_at': exp.toIso8601String(),
          })
          .select(
            'id, family_id, label, wifi_credentials, emergency_contacts, allergies, '
            'locations, created_by, expires_at, revoked_at, created_at, updated_at',
          )
          .single();
      final link = BabysitterLink.fromMap(Map<String, dynamic>.from(row));
      return Result.success(CreatedBabysitterLink(link: link, rawToken: raw));
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: 'babysitter_link_create_failed', message: e.message),
      );
    } catch (e) {
      return Result.failure(
        Failure(code: 'babysitter_link_create_failed', message: '$e'),
      );
    }
  }

  Future<Result<List<BabysitterLink>>> listLinks({
    required String familyId,
  }) async {
    if (_client.auth.currentUser?.id == null) {
      return Result.failure(
        Failure(code: 'auth_required', message: 'Sign in required'),
      );
    }
    try {
      final rows = await _client
          .from('babysitter_links')
          .select(
            'id, family_id, label, wifi_credentials, emergency_contacts, allergies, '
            'locations, created_by, expires_at, revoked_at, created_at, updated_at',
          )
          .eq('family_id', familyId)
          .order('created_at', ascending: false);
      final list = <BabysitterLink>[];
      for (final r in rows) {
        list.add(BabysitterLink.fromMap(Map<String, dynamic>.from(r)));
      }
      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: 'babysitter_link_list_failed', message: e.message),
      );
    } catch (e) {
      return Result.failure(
        Failure(code: 'babysitter_link_list_failed', message: '$e'),
      );
    }
  }

  Future<Result<void>> revokeLink({required String linkId}) async {
    if (_client.auth.currentUser?.id == null) {
      return Result.failure(
        Failure(code: 'auth_required', message: 'Sign in required'),
      );
    }
    try {
      await _client
          .from('babysitter_links')
          .update({
            'revoked_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', linkId);
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: 'babysitter_link_revoke_failed', message: e.message),
      );
    } catch (e) {
      return Result.failure(
        Failure(code: 'babysitter_link_revoke_failed', message: '$e'),
      );
    }
  }

  /// Calls `public.babysitter_scope` (works with anon or authenticated clients).
  Future<Result<BabysitterScopeResolution>> introspectToken(
    String rawToken, {
    Map<String, dynamic>? clientMeta,
  }) async {
    try {
      final data = clientMeta == null || clientMeta.isEmpty
          ? await _client.rpc<dynamic>(
              'babysitter_scope',
              params: {'p_token': rawToken},
            )
          : await _client.rpc<dynamic>(
              'babysitter_scope',
              params: {'p_token': rawToken, 'p_client_meta': clientMeta},
            );
      if (data is! Map) {
        return Result.failure(
          Failure(
            code: 'babysitter_scope_invalid_response',
            message: 'Bad RPC shape',
          ),
        );
      }
      final res = BabysitterScopeResolution.fromJson(
        Map<String, dynamic>.from(data),
      );
      return switch (res.status) {
        BabysitterScopeStatus.ok => Result.success(res),
        BabysitterScopeStatus.expired => Result.failure(
          Failure(
            code: 'babysitter_link_expired',
            message: 'This link has expired.',
          ),
        ),
        BabysitterScopeStatus.revoked => Result.failure(
          Failure(
            code: 'babysitter_link_revoked',
            message: 'This link was revoked.',
          ),
        ),
        BabysitterScopeStatus.invalid => Result.failure(
          Failure(
            code: 'babysitter_link_invalid',
            message: 'Unknown or malformed link.',
          ),
        ),
      };
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(code: 'babysitter_scope_rpc_failed', message: e.message),
      );
    } catch (e) {
      return Result.failure(
        Failure(code: 'babysitter_scope_rpc_failed', message: '$e'),
      );
    }
  }
}
