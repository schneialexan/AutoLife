// Rejects unknown literals cast to public.sensitivity_tier in SQL migrations.

import 'dart:io';

const _allowed = {
  'public_family',
  'private_member',
  'health_locked',
  'finance_locked',
};

Future<void> main() async {
  final root = _findRepoRoot();
  final dir = Directory('$root/supabase/migrations');
  if (!dir.existsSync()) {
    stderr.writeln('sensitivity_tier_lint: missing migrations dir');
    exit(2);
  }
  final re = RegExp(
    r"'([^']+)'\s*::\s*(public\.)?sensitivity_tier\b",
    caseSensitive: false,
  );
  final violations = <String>[];
  for (final ent in dir.listSync().whereType<File>().where(
    (f) => f.path.toLowerCase().endsWith('.sql'),
  )) {
    final body = ent.readAsStringSync();
    for (final m in re.allMatches(body)) {
      final label = m.group(1);
      if (label == null) continue;
      if (!_allowed.contains(label)) {
        violations.add('${ent.path}: unknown tier literal "$label"');
      }
    }
  }
  if (violations.isNotEmpty) {
    stderr.writeln(
      'sensitivity_tier_lint: invalid sensitivity_tier literals '
      '(closed set: ${_allowed.join(", ")}):',
    );
    for (final v in violations) {
      stderr.writeln('  $v');
    }
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
