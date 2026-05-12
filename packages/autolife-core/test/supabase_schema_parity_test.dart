import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Directory _findRepoRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 8; i++) {
    final migration = File(
      p.join(dir.path, 'supabase', 'migrations', '0001_init_system_events.sql'),
    );
    if (migration.existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError(
    'Could not locate repo root (file supabase/migrations/0001_init_system_events.sql). '
    'Run tests from the monorepo root or set AUTOLIFE_REPO_ROOT.',
  );
}

/// Ensures SQL column names stay aligned with [packages/autolife-core] JSON contracts.
void main() {
  late String repoRoot;

  setUpAll(() {
    final fromEnv = Platform.environment['AUTOLIFE_REPO_ROOT'];
    repoRoot = (fromEnv != null && fromEnv.isNotEmpty)
        ? fromEnv
        : _findRepoRoot().path;
  });

  test('system_event migration defines core columns', () {
    final sql = File(
      p.join(repoRoot, 'supabase/migrations/0001_init_system_events.sql'),
    ).readAsStringSync();
    const columns = <String>[
      'tenant_id',
      'actor_id',
      'module',
      'type',
      'payload',
      'idempotency_key',
      'occurred_at',
      'ordering_tag',
      'schema_version',
    ];
    for (final c in columns) {
      expect(
        sql.contains(c),
        isTrue,
        reason: 'Expected 0001_init_system_events.sql to include `$c`',
      );
    }
  });

  test('event_delivery migration defines core columns', () {
    final sql = File(
      p.join(repoRoot, 'supabase/migrations/0001_init_system_events.sql'),
    ).readAsStringSync();
    const columns = <String>[
      'event_id',
      'consumer',
      'attempt',
      'status',
      'last_error',
      'next_attempt_at',
    ];
    for (final c in columns) {
      expect(
        sql.contains(c),
        isTrue,
        reason: 'Expected 0001_init_system_events.sql to include `$c`',
      );
    }
    expect(sql, contains('dead_letter'));
    expect(sql, contains('pending'));
    expect(sql, contains('succeeded'));
    expect(sql, contains('failed'));
  });

  test('sync incremental migration adds updated_at to mirrored tables', () {
    final sql = File(
      p.join(
        repoRoot,
        'supabase/migrations/0011_sync_incremental_timestamps.sql',
      ),
    ).readAsStringSync();
    for (final t in [
      'system_event',
      'event_delivery',
      'family',
      'profile',
      'membership',
    ]) {
      expect(sql.toLowerCase(), contains('public.$t'));
      expect(sql, contains('updated_at'));
    }
  });

  test('family tenancy migrations define canonical tables', () {
    final sql = File(
      p.join(repoRoot, 'supabase/migrations/20260512000100_family_tenancy.sql'),
    ).readAsStringSync();
    expect(sql.toLowerCase(), contains('public.families'));
    expect(sql.toLowerCase(), contains('public.memberships'));
    expect(sql.toLowerCase(), contains('family_invitations'));
    expect(sql, contains('token_hash'));

    final fnSql = File(
      p.join(
        repoRoot,
        'supabase/migrations/20260512000110_family_tenancy_functions.sql',
      ),
    ).readAsStringSync();
    expect(fnSql.toLowerCase(), contains('accept_invitation'));
    expect(fnSql.toLowerCase(), contains('revoke_invitation'));
  });

  test('phase 2.3 policy migrations install role enum + policy tables', () {
    final roleSql = File(
      p.join(repoRoot, 'supabase/migrations/20260512000200_role_enum.sql'),
    ).readAsStringSync();
    expect(roleSql.toLowerCase(), contains('family_role'));
    expect(roleSql.toLowerCase(), contains('public.memberships'));

    final grantsSql = File(
      p.join(
        repoRoot,
        'supabase/migrations/20260512000210_capability_matrix.sql',
      ),
    ).readAsStringSync();
    expect(grantsSql.toLowerCase(), contains('capability_grants'));
    expect(grantsSql.toLowerCase(), contains('capability_matrix_default'));

    final approvalSql = File(
      p.join(
        repoRoot,
        'supabase/migrations/20260512000220_approval_engine.sql',
      ),
    ).readAsStringSync();
    expect(approvalSql.toLowerCase(), contains('approval_requests'));
    expect(approvalSql.toLowerCase(), contains('approval_auto_rules'));
    expect(approvalSql.toLowerCase(), contains('enforce_capability'));
  });

  test(
    'connector credential migration stores secrets only via Vault helpers',
    () {
      final sql = File(
        p.join(repoRoot, 'supabase/migrations/0020_connector_credentials.sql'),
      ).readAsStringSync();
      final lowered = sql.toLowerCase();
      for (final token in [
        'vault_secret_id',
        'connector_event',
        'integration_store_connector_secret',
        'vault.create_secret',
      ]) {
        expect(
          lowered.contains(token),
          isTrue,
          reason: 'Expected 0020_connector_credentials.sql to mention $token',
        );
      }
      final forbidden = ['access_token', 'refresh_token', 'client_secret'];
      final credentialBlock = lowered.split(
        'create table public.connector_credential',
      )[1];
      final credentialChunk = credentialBlock.split('create table')[0];
      for (final phrase in forbidden) {
        expect(
          credentialChunk.contains(phrase),
          isFalse,
          reason:
              'connector_credential must not declare plaintext secret columns like `$phrase`',
        );
      }
    },
  );

  test('calendar phase 3.2 migration defines calendar tables + RLS', () {
    final sql = File(
      p.join(
        repoRoot,
        'supabase/migrations/20260512170000_calendar_phase_3_2.sql',
      ),
    ).readAsStringSync();
    for (final token in [
      'create table public.calendar_events',
      'calendar_recurrence_exceptions',
      'calendar_sync_links',
      'calendar_import_batches',
      'calendar_events_member',
      'external_uid',
      'sensitivity_assignments',
    ]) {
      expect(
        sql.contains(token),
        isTrue,
        reason: 'Expected calendar migration to include $token',
      );
    }
  });

  test('calendar rich fields migration adds jsonb columns', () {
    final sql = File(
      p.join(
        repoRoot,
        'supabase/migrations/20260512180000_calendar_event_rich_fields.sql',
      ),
    ).readAsStringSync();
    for (final token in [
      'event_links',
      'event_attachments',
      'related_event_ids',
      'event_attendees',
      'sensitivity_assignments',
    ]) {
      expect(
        sql.contains(token),
        isTrue,
        reason: 'Expected rich-fields migration to include $token',
      );
    }
  });
}
