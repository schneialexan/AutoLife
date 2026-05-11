import 'dart:io';

import 'package:autolife_core/autolife_core.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

/// Exercises [TenancyService] and [RolePolicyService] against a live Supabase
/// stack with RLS enabled (Phase 2.4).
///
/// Local/CI: export `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`
/// (`supabase status -o env` on a running stack).
void main() {
  final url = Platform.environment['SUPABASE_URL'];
  final anon = Platform.environment['SUPABASE_ANON_KEY'];
  final service = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];

  final haveKeys =
      url != null &&
      anon != null &&
      service != null &&
      url.isNotEmpty &&
      anon.isNotEmpty &&
      service.isNotEmpty;

  test(
    'TenancyService + RLS: create family, list, stranger denied family row',
    () async {
      final u = url!;
      final a = anon!;
      final s = service!;
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final admin = SupabaseClient(u, s);
      const password = 'RlssTest99!';

      final ownerEmail = 'rls_owner_$stamp@example.com';
      final strangerEmail = 'rls_out_$stamp@example.com';

      final ownerRes = await admin.auth.admin.createUser(
        AdminUserAttributes(
          email: ownerEmail,
          password: password,
          emailConfirm: true,
        ),
      );
      final ownerId = ownerRes.user!.id;

      await admin.auth.admin.createUser(
        AdminUserAttributes(
          email: strangerEmail,
          password: password,
          emailConfirm: true,
        ),
      );

      final ownerClient = SupabaseClient(u, a);
      await ownerClient.auth.signInWithPassword(
        email: ownerEmail,
        password: password,
      );

      final tenancy = SupabaseTenancyService(ownerClient);
      final created = await tenancy.createFamily(name: 'RLS IT $stamp');
      final famId = created.when(
        success: (e) => e.family.id,
        failure: (f) => throw Exception('${f.code} ${f.message}'),
      );

      final listed = await tenancy.listMyActiveEnrollments();
      listed.when(
        success: (list) =>
            expect(list.any((e) => e.family.id == famId), isTrue),
        failure: (f) => fail(f.code),
      );

      final strangerClient = SupabaseClient(u, a);
      await strangerClient.auth.signInWithPassword(
        email: strangerEmail,
        password: password,
      );

      final probe = await strangerClient
          .from('families')
          .select('id')
          .eq('id', famId)
          .maybeSingle();
      expect(probe, isNull);

      await admin.auth.admin.deleteUser(ownerId);
    },
    skip: haveKeys
        ? false
        : 'Set Supabase URL/anon/service keys for integration',
  );

  test(
    'RolePolicyService reads capability_grants under RLS',
    () async {
      final u = url!;
      final a = anon!;
      final s = service!;
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final admin = SupabaseClient(u, s);
      const password = 'RlssTest99!';
      final email = 'rls_pol_$stamp@example.com';

      await admin.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );

      final client = SupabaseClient(u, a);
      await client.auth.signInWithPassword(email: email, password: password);

      final tenancy = SupabaseTenancyService(client);
      final created = await tenancy.createFamily(name: 'Pol $stamp');
      final famId = created.when(
        success: (e) => e.family.id,
        failure: (f) => throw Exception(f.code),
      );

      final policy = RolePolicyService(SupabaseCapabilityGrantSource(client));
      final grant = await policy.resolvedGrant(
        familyId: famId,
        role: FamilyRole.owner,
        capability: Capability.familyViewMembers,
      );

      grant.when(
        success: (g) => expect(g.granted, isTrue),
        failure: (f) => fail(f.code),
      );
    },
    skip: haveKeys
        ? false
        : 'Set Supabase URL/anon/service keys for integration',
  );

  test(
    'BabysitterLinkService: owner mints link, anonymous client introspects scope',
    () async {
      final u = url!;
      final a = anon!;
      final s = service!;
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final admin = SupabaseClient(u, s);
      const password = 'RlssTest99!';
      final email = 'rls_bs_$stamp@example.com';

      final createdUser = await admin.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );
      final ownerId = createdUser.user!.id;

      final ownerClient = SupabaseClient(u, a);
      await ownerClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final tenancy = SupabaseTenancyService(ownerClient);
      final fam = await tenancy.createFamily(name: 'BS $stamp');
      final famId = fam.when(
        success: (e) => e.family.id,
        failure: (f) => throw Exception(f.code),
      );

      final ownerSvc = BabysitterLinkService(ownerClient);
      final link = await ownerSvc.createLink(
        familyId: famId,
        toggles: const BabysitterScopeToggles(
          wifiCredentials: true,
          allergies: true,
        ),
      );
      final raw = link.when(
        success: (c) => c.rawToken,
        failure: (f) => throw Exception('${f.code} ${f.message}'),
      );

      final anonClient = SupabaseClient(u, a);
      final anonSvc = BabysitterLinkService(anonClient);
      final intro = await anonSvc.introspectToken(raw);
      intro.when(
        success: (res) {
          expect(res.status, BabysitterScopeStatus.ok);
          expect(res.familyId, famId);
          expect(res.resources, contains('wifi_credentials'));
          expect(res.resources, contains('allergies'));
          expect(res.resources.contains('locations'), isFalse);
        },
        failure: (f) => fail('${f.code} ${f.message}'),
      );

      await admin.auth.admin.deleteUser(ownerId);
    },
    skip: haveKeys
        ? false
        : 'Set Supabase URL/anon/service keys for integration',
  );
}
