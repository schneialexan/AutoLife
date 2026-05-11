// Enforces coverage for RLS helpers: each predicate must appear in RLS SQL tests.
// Stand-in when pg_prove --coverage is unavailable.

import 'dart:io';

Future<void> main() async {
  final repoRoot = _findRepoRoot();
  final helpersFile = File(
    '$repoRoot/supabase/migrations/20260512000300_rls_helpers.sql',
  );
  if (!helpersFile.existsSync()) {
    stderr.writeln('rls_coverage_gate: missing ${helpersFile.path}');
    exit(2);
  }
  final helperBody = helpersFile.readAsStringSync();
  final required = <String>[];
  final re = RegExp(
    r'create\s+or\s+replace\s+function\s+public\.(\w+)\s*\(',
    caseSensitive: false,
  );
  for (final m in re.allMatches(helperBody)) {
    final name = m.group(1);
    if (name != null) {
      required.add(name);
    }
  }
  if (required.isEmpty) {
    stderr.writeln('rls_coverage_gate: no helpers found in migration');
    exit(2);
  }

  final testDir = Directory('$repoRoot/supabase/tests');
  if (!testDir.existsSync()) {
    stderr.writeln('rls_coverage_gate: missing supabase/tests');
    exit(2);
  }
  final buf = StringBuffer();
  final applyMigration = File(
    '$repoRoot/supabase/migrations/20260512000310_apply_rls_phase2.sql',
  );
  if (applyMigration.existsSync()) {
    buf.write(applyMigration.readAsStringSync());
    buf.write('\n');
  }
  await for (final ent in testDir.list(recursive: true)) {
    if (ent is File && ent.path.endsWith('.sql')) {
      buf.write(ent.readAsStringSync());
      buf.write('\n');
    }
  }
  final haystack = buf.toString();
  final missing = <String>[];
  for (final name in required) {
    final needle = RegExp(r'\b' + RegExp.escape(name) + r'\s*\(');
    if (!needle.hasMatch(haystack)) {
      missing.add(name);
    }
  }
  if (missing.isNotEmpty) {
    stderr.writeln(
      'rls_coverage_gate: helpers not referenced in supabase/tests/**/*.sql: '
      '${missing.join(", ")}',
    );
    exit(1);
  }
}

String _findRepoRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 10; i++) {
    if (File('${dir.path}/supabase/config.toml').existsSync()) {
      return dir.path;
    }
    dir = dir.parent;
  }
  return Directory.current.path;
}
