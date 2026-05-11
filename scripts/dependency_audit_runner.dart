// Aggregates `dart pub outdated`, `flutter pub outdated`, and Edge `npm audit` into one JSON report.
//
// Phase 2.6 policy:
// - npm **critical**: fail unless each advisory id appears in dependency_audit_allowlist.yaml
//   with valid remediation_deadline (YYYY-MM-DD) that is today or later.
// - Dart / Flutter payloads are informational (no CVE feed in pub).
//
// Usage: dart run scripts/dependency_audit_runner.dart [--json-out PATH]

import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

void main(List<String> args) {
  final encoder = JsonEncoder.withIndent('  ');
  final repoRootAbs = _findRepoAbs();
  final repoNorm = normalizeSlashes(repoRootAbs);

  Directory.current = repoNorm;

  final outArg = args.indexOf('--json-out');
  final outPath = outArg >= 0 && outArg + 1 < args.length
      ? args[outArg + 1]
      : '$repoNorm/reports/security/dependency_audit_report.json';

  dynamic dartOutdated;
  final dartRs = Process.runSync(
    'dart',
    ['pub', 'outdated', '--json'],
    workingDirectory: repoNorm,
    runInShell: false,
    environment: Platform.environment,
  );
  try {
    dartOutdated = dartRs.stdout.toString().trim().isEmpty
        ? <String, dynamic>{}
        : jsonDecode(dartRs.stdout as String);
  } catch (_) {
    dartOutdated = <String, dynamic>{
      'exit_code': dartRs.exitCode,
      'stdout': '${dartRs.stdout}',
      'stderr': '${dartRs.stderr}',
    };
  }

  final flutterPackages = <Map<String, dynamic>>[];
  for (final dir in flutterPackageRoots(repoNorm)) {
    final abs = dir.absolute.path;
    final rel = relPath(repoNorm, abs);
    late final ProcessResult fr;
    try {
      fr = Process.runSync(
        'flutter',
        ['pub', 'outdated', '--json'],
        workingDirectory: abs,
        runInShell: false,
        environment: Platform.environment,
      );
    } on ProcessException catch (e) {
      flutterPackages.add({
        'path': rel,
        'skipped': true,
        'reason':
            'flutter not on PATH (${e.message}) — run from dev machine with Flutter installed or use CI',
      });
      continue;
    }
    try {
      final raw = fr.stdout.toString().trim();
      flutterPackages.add({
        'path': rel,
        'exit_code': fr.exitCode,
        'outdated_json': raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw),
      });
    } catch (e) {
      flutterPackages.add({
        'path': rel,
        'exit_code': fr.exitCode,
        'error': '$e',
        'stdout': '${fr.stdout}',
        'stderr': '${fr.stderr}',
      });
    }
  }

  final npmBlocks = <Map<String, dynamic>>[];
  final criticalRows = <Map<String, dynamic>>[];

  final functionsRoot = Directory('$repoNorm/supabase/functions');
  if (functionsRoot.existsSync()) {
    for (final d in functionsRoot.listSync().whereType<Directory>()) {
      if (!File('${d.path}/package.json').existsSync()) continue;

      ProcessResult npm;
      try {
        npm = Process.runSync(
          'npm',
          ['audit', '--json', '--omit=dev'],
          workingDirectory: d.path,
          runInShell: false,
          environment: Platform.environment,
        );
      } on ProcessException catch (e) {
        npmBlocks.add({
          'path': relPath(repoNorm, d.absolute.path),
          'skipped': true,
          'reason':
              'npm not on PATH (${e.message}) — install Node or rely on CI',
        });
        continue;
      }

      Object? parsed;
      try {
        final s = npm.stdout.toString().trim();
        parsed = s.isEmpty ? <String, dynamic>{} : jsonDecode(s);
      } catch (_) {
        parsed = {'stdout': '${npm.stdout}', 'stderr': '${npm.stderr}'};
      }
      npmBlocks.add({
        'path': relPath(repoNorm, d.absolute.path),
        'exit_code': npm.exitCode,
        'audit_json': parsed,
      });
      criticalRows.addAll(
        criticalEntriesFromAuditJson(parsed, d.absolute.path),
      );
    }
  }

  final byId = <String, Map<String, dynamic>>{};
  for (final row in criticalRows) {
    final id = '${row['id']}';
    if (id.isEmpty) continue;
    byId[id] = row;
  }
  final deduped = byId.values.toList();

  final report = <String, dynamic>{
    'generated_at': DateTime.now().toUtc().toIso8601String(),
    'repo_root': repoNorm,
    'dart_pub_outdated': dartOutdated,
    'flutter_packages': flutterPackages,
    'npm': npmBlocks,
    'critical_rows': deduped,
  };

  final outFile = File(outPath);
  outFile.parent.createSync(recursive: true);
  outFile.writeAsStringSync(encoder.convert(report));

  final allowRaw = File(
    '$repoNorm/scripts/dependency_audit_allowlist.yaml',
  ).readAsStringSync();
  final allowlist = CriticalAllowlist.parse(allowRaw);

  final today = dateOnlyUtc(DateTime.now());
  final errors = <String>[];

  if (dartRs.exitCode != 0 &&
      dartRs.exitCode != 1 &&
      dartRs.stderr.toString().trim().contains('could not')) {
    // Non-fatal analyzer noise
  }

  for (final row in deduped) {
    final gid = '${row['id']}';
    final entry = allowlist.entryFor(gid);
    if (entry == null) {
      errors.add(
        'CRITICAL advisory $gid (${row["package"]}, ${relPath(repoNorm, row["path"]! as String)}) '
        '- remediate deps or waive in scripts/dependency_audit_allowlist.yaml with '
        'id, accepted_at (YYYY-MM-DD), remediation_deadline (≤ accepted_at + 14d)',
      );
      continue;
    }

    final deadline = parseDate(entry.remediationDeadline);
    final accepted =
        parseDate(entry.acceptedAt) ??
        deadline?.subtract(const Duration(days: 1));

    if (deadline == null) {
      errors.add('Allowlisted $gid: invalid remediation_deadline');
      continue;
    }

    if (accepted != null && deadline.difference(accepted).inDays > 14) {
      stderr.writeln(
        'WARN: $gid remediation_deadline is more than 14 days after accepted_at (${entry.acceptedAt}) '
        '(Phase 2.6 SLA)',
      );
    }

    if (today.isAfter(deadline)) {
      errors.add(
        '$gid is still reported critical after remediation_deadline ${entry.remediationDeadline} — upgrade deps',
      );
    }

    final acceptDay = accepted == null ? null : dateOnlyUtc(accepted);
    if (acceptDay != null && calendarDaysBetween(today, acceptDay) > 7) {
      stderr.writeln(
        'WARN: Critical $gid has been waived for over 7 calendar days since accepted_at (${entry.acceptedAt})',
      );
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln(encoder.convert(errors));
    exit(1);
  }

  stdout.writeln('dependency_audit_runner: OK → $outPath');
}

class CriticalAllowlistEntry {
  CriticalAllowlistEntry({
    required this.id,
    required this.remediationDeadline,
    required this.acceptedAt,
  });

  final String id;
  final String remediationDeadline;
  final String acceptedAt;
}

class CriticalAllowlist {
  CriticalAllowlist(this._byIdLower);

  final Map<String, CriticalAllowlistEntry> _byIdLower;

  CriticalAllowlistEntry? entryFor(String id) =>
      _byIdLower[id.trim().toLowerCase()];

  static CriticalAllowlist parse(String raw) {
    final y = loadYaml(raw);
    final map = <String, CriticalAllowlistEntry>{};
    if (y is YamlMap) {
      final list = y['critical'];
      if (list is YamlList) {
        for (final item in list) {
          if (item is! YamlMap) continue;
          final id = '${item['id'] ?? ''}'.trim();
          if (id.isEmpty) continue;
          map[id.toLowerCase()] = CriticalAllowlistEntry(
            id: id,
            remediationDeadline: '${item['remediation_deadline'] ?? ''}'.trim(),
            acceptedAt: '${item['accepted_at'] ?? ''}'.trim(),
          );
        }
      }
    }
    return CriticalAllowlist(map);
  }
}

List<Map<String, dynamic>> criticalEntriesFromAuditJson(
  Object? parsed,
  String functionDirAbs,
) {
  if (parsed is! Map<String, dynamic>) return [];
  final vulns = parsed['vulnerabilities'];
  if (vulns is! Map<String, dynamic>) return [];

  final hits = <Map<String, dynamic>>[];
  for (final e in vulns.entries) {
    final pkgName = e.key;
    final blob = e.value;
    if (blob is! Map<String, dynamic>) continue;
    if ('${blob['severity']}'.toLowerCase() != 'critical') continue;

    final id = advisoryIdFromVia(blob['via']);
    if (id.isEmpty) continue;
    hits.add({
      'id': id,
      'package': pkgName,
      'path': functionDirAbs,
      'severity': 'critical',
    });
  }
  return hits;
}

String advisoryIdFromVia(dynamic via) {
  final ghsaRe = RegExp(
    r'GHSA-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}',
    caseSensitive: false,
  );
  if (via is List) {
    for (final e in via) {
      if (e is Map<String, dynamic>) {
        final urlMatch = ghsaRe.firstMatch('${e['url']}');
        if (urlMatch != null) return urlMatch.group(0)!;
      }
      if (e is String) {
        final m = ghsaRe.firstMatch(e);
        if (m != null) return m.group(0)!;
      }
    }
  }
  if (via is String) {
    final m = ghsaRe.firstMatch(via);
    if (m != null) return m.group(0)!;
  }
  return '';
}

DateTime dateOnlyUtc(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);

DateTime? parseDate(String iso) {
  if (iso.isEmpty) return null;
  final d = DateTime.tryParse(iso);
  return d == null ? null : dateOnlyUtc(d);
}

int calendarDaysBetween(DateTime a, DateTime b) => a.difference(b).inDays;

String normalizeSlashes(String path) => Directory(
  path.replaceAll(RegExp(r'\\'), Platform.pathSeparator),
).absolute.path.replaceAll(RegExp(r'\\'), '/');

String relPath(String repoNormForward, String targetAbsRaw) {
  final target = normalizeSlashes(targetAbsRaw);
  final prefix = repoNormForward.endsWith('/')
      ? repoNormForward
      : '$repoNormForward/';
  if (target.startsWith(prefix)) return target.substring(prefix.length);
  return target;
}

String _findRepoAbs() {
  var dir = Directory.current;
  for (var i = 0; i < 12; i++) {
    if (File('${dir.path}/supabase/config.toml').existsSync()) {
      return dir.absolute.path;
    }
    dir = dir.parent;
  }
  return Directory.current.absolute.path;
}

bool _skippedPath(String posixPathLower) =>
    posixPathLower.contains('.dart_tool/') ||
    posixPathLower.contains('/build/') ||
    posixPathLower.endsWith('/generated_plugin_registrant.dart');

List<Directory> flutterPackageRoots(String repoNorm) {
  final out = <Directory>[];
  final rootDir = Directory(repoNorm);
  if (!rootDir.existsSync()) return out;

  for (final e in rootDir.listSync(recursive: true, followLinks: false)) {
    if (e is! File || !e.path.endsWith('pubspec.yaml')) continue;
    final rel = relPath(
      repoNorm,
      e.parent.path,
    ).toLowerCase().replaceAll(RegExp(r'\\'), '/');
    if (_skippedPath(rel)) continue;

    late final String text;
    try {
      text = File(e.path).readAsStringSync();
    } catch (_) {
      continue;
    }

    final isFlutterPkg = RegExp(
      r'^\s*flutter:\s',
      multiLine: true,
    ).hasMatch(text);
    final isFlutterSdk = RegExp(
      r'^\s*sdk:\s*flutter\s*$',
      multiLine: true,
    ).hasMatch(text);
    if (!(isFlutterPkg || isFlutterSdk)) continue;

    final dir = Directory(e.parent.path);
    if (!out.any(
      (existing) =>
          normalizeSlashes(existing.absolute.path) ==
          normalizeSlashes(dir.absolute.path),
    )) {
      out.add(dir);
    }
  }
  return out;
}
