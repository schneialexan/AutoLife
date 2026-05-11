import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Directory _findRepoRoot() {
  var dir = Directory.current;
  // When tests run via `dart test` from packages/autolife-core, cwd is the package.
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
}
