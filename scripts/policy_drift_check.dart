// Compares live RLS policies to supabase/policies/rls_policy_registry.yaml.

import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:yaml/yaml.dart';

Future<void> main(List<String> args) async {
  final repoRoot = _findRepoRoot();
  final registryPath = args.isNotEmpty
      ? args.first
      : '$repoRoot/supabase/policies/rls_policy_registry.yaml';
  final allowlistPath = '$repoRoot/supabase/policies/rls_drift_allowlist.yaml';

  var dbUrl =
      Platform.environment['SUPABASE_DB_URL'] ??
      Platform.environment['DB_URL'] ??
      Platform.environment['DATABASE_URL'];
  if (dbUrl == null || dbUrl.isEmpty) {
    stderr.writeln(
      'policy_drift_check: set SUPABASE_DB_URL, DB_URL, or DATABASE_URL',
    );
    exit(2);
  }
  dbUrl = dbUrl.trim();
  if ((dbUrl.startsWith('"') && dbUrl.endsWith('"')) ||
      (dbUrl.startsWith("'") && dbUrl.endsWith("'"))) {
    dbUrl = dbUrl.substring(1, dbUrl.length - 1);
  }

  if (!dbUrl.contains('sslmode=')) {
    dbUrl = dbUrl.contains('?')
        ? '$dbUrl&sslmode=disable'
        : '$dbUrl?sslmode=disable';
  }

  final registryRaw = File(registryPath).readAsStringSync();
  final registry = loadYaml(registryRaw);
  if (registry is! YamlMap) {
    stderr.writeln('registry: invalid yaml root');
    exit(2);
  }
  final tablesYaml = registry['tables'];
  if (tablesYaml is! YamlMap) {
    stderr.writeln('registry: missing tables: map');
    exit(2);
  }

  final allowlisted = _readAllowlist(allowlistPath);

  final conn = await Connection.openFromUrl(dbUrl);
  try {
    final rlsTables = await _rlsTableNames(conn);
    final policies = await _policyMap(conn);

    final errors = <String>[];
    final registryTables = tablesYaml.keys.cast<String>().toSet();

    for (final t in rlsTables) {
      if (allowlisted.contains(t)) {
        continue;
      }
      if (!registryTables.contains(t)) {
        errors.add(
          'Table "$t" has RLS enabled but is not listed in rls_policy_registry.yaml',
        );
      }
    }

    for (final e in tablesYaml.entries) {
      final table = e.key as String;
      final value = e.value;
      if (value is! YamlMap) {
        errors.add('registry entry for "$table" must be a map');
        continue;
      }
      if (!rlsTables.contains(table)) {
        errors.add(
          'Registry lists "$table" but table is missing or RLS is disabled',
        );
        continue;
      }
      final expected =
          (value['policies'] as YamlList?)?.map((p) => p.toString()).toSet() ??
          {};
      final actual = policies[table] ?? {};
      final missing = expected.difference(actual);
      final extra = actual.difference(expected);
      if (missing.isNotEmpty) {
        errors.add('Table "$table" missing policies: ${missing.join(", ")}');
      }
      if (extra.isNotEmpty) {
        errors.add(
          'Table "$table" has undocumented policies: ${extra.join(", ")}',
        );
      }
    }

    final report = {
      'ok': errors.isEmpty,
      'registryPath': registryPath,
      'errors': errors,
      'tables_checked': registryTables.length,
    };
    stdout.writeln(jsonEncode(report));

    if (errors.isNotEmpty) {
      for (final e in errors) {
        stderr.writeln(e);
      }
      exit(1);
    }
  } finally {
    await conn.close();
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

Set<String> _readAllowlist(String path) {
  final f = File(path);
  if (!f.existsSync()) {
    return {};
  }
  final y = loadYaml(f.readAsStringSync());
  if (y is! YamlMap) {
    return {};
  }
  final t = y['tables'];
  if (t is YamlList) {
    return t.map((e) => e.toString()).toSet();
  }
  return {};
}

Future<Set<String>> _rlsTableNames(Connection conn) async {
  final rs = await conn.execute(
    Sql.named('''
SELECT c.relname::text
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = @schema
  AND c.relkind = 'r'
  AND c.relrowsecurity = true
ORDER BY 1
'''),
    parameters: {'schema': 'public'},
  );
  final names = <String>{};
  for (final row in rs) {
    names.add(row[0]! as String);
  }
  return names;
}

Future<Map<String, Set<String>>> _policyMap(Connection conn) async {
  final rs = await conn.execute(
    Sql.named('''
SELECT tablename::text, policyname::text
FROM pg_policies
WHERE schemaname = @schema
ORDER BY 1, 2
'''),
    parameters: {'schema': 'public'},
  );
  final map = <String, Set<String>>{};
  for (final row in rs) {
    final table = row[0]! as String;
    final pol = row[1]! as String;
    map.putIfAbsent(table, () => <String>{}).add(pol);
  }
  return map;
}
