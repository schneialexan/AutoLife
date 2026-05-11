// Scans tracked files + optional git history for secret-like patterns and entropy hits.
//
// Usage:
//   dart run scripts/secret_scan.dart
//   dart run scripts/secret_scan.dart --history --max-patch-chars 50000000

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:yaml/yaml.dart';

Future<void> main(List<String> args) async {
  final useHistory =
      args.contains('--history') ||
      Platform.environment['SECRET_SCAN_HISTORY'] == '1';
  final maxPatchChars = _intArg(args, '--max-patch-chars', 20 * 1024 * 1024);
  final repoRoot = _findRepoRoot();

  final allowRaw = File(
    '$repoRoot/scripts/secret_scan_allowlist.yaml',
  ).readAsStringSync();
  final allow = SecretAllowlist.load(allowRaw);

  final patterns = [
    SecretPattern(
      RegExp(r'\bsk_live_[0-9a-zA-Z]{20,}', caseSensitive: false),
      description: 'Stripe live secret',
    ),
    SecretPattern(
      RegExp(
        r'xox[baprs]-[0-9]{11,}-[0-9]{10,}-[a-z0-9]{20,}',
        caseSensitive: false,
      ),
      description: 'Slack token',
    ),
    SecretPattern(
      RegExp(r'AKIA[0-9A-Z]{16}', caseSensitive: false),
      description: 'AWS access key',
    ),
    SecretPattern(
      RegExp(r'\bBEGIN (RSA |EC )?PRIVATE KEY', caseSensitive: false),
      description: 'PEM private key',
    ),
    SecretPattern(
      RegExp(r'(?:gh[pousr]|[Pp]AT)[A-Za-z0-9_\-]{36,}', caseSensitive: false),
      description: 'GitHub PAT-like',
    ),
    SecretPattern(
      RegExp(
        r'(\bPASSWORD\b|\bAPI_KEY\b|\bSECRET\b)\s*[:=]\s*[ "\x27]?[0-9a-zA-Z/+=]{24,}',
        caseSensitive: false,
      ),
      description: 'Inline password/api key literal',
    ),
    SecretPattern(
      RegExp(
        r'\beyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{20,}',
      ),
      description: 'Three-part JWT-shaped token',
    ),
  ];

  final hits = <String>[];

  if (useHistory) {
    stdout.writeln(
      'secret_scan: scanning git history (patch cap $maxPatchChars chars)...',
    );
    final patch = Process.runSync('git', [
      '-C',
      repoRoot,
      'log',
      '-p',
      '--all',
      '--no-renames',
    ]);
    final raw = processOut(patch.stdout as Object?);
    final capped = raw.length > maxPatchChars
        ? raw.substring(0, maxPatchChars)
        : raw;
    hits.addAll(
      _scanText(capped.split('\n'), '<git history>', allow, patterns),
    );
    if (stderrText(patch).isNotEmpty) stderr.writeln(stderrText(patch));
    if (patch.exitCode != 0 && patch.exitCode != 1) {
      stderr.writeln('secret_scan: git log failed (${patch.exitCode})');
      exit(2);
    }
  } else {
    final ls = Process.runSync('git', ['-C', repoRoot, 'ls-files', '-z']);
    if (ls.exitCode != 0) {
      stderr.writeln(processOut(ls.stderr));
      stderr.writeln('secret_scan: git ls-files failed');
      exit(2);
    }
    final files = processOut(
      ls.stdout,
    ).split('\x00').where((String e) => e.isNotEmpty).toList();
    var scanned = 0;
    for (final rel in files) {
      final path = filePathJoin(repoRoot, rel);
      if (_skipTracked(rel, allow)) continue;
      final bin = File(path);
      if (!bin.existsSync()) continue;

      scanned++;
      if (scanBinaryPath(rel)) continue;
      List<String> lines;
      try {
        lines = bin.readAsStringSync().split('\n');
      } catch (_) {
        continue;
      }
      hits.addAll(_scanText(lines, rel, allow, patterns));
    }
    stdout.writeln('secret_scan: scanned $scanned tracked text files.');
  }

  if (hits.isEmpty) {
    stdout.writeln(jsonEncode({'ok': true, 'hits': 0}));
    exit(0);
  }

  for (final h in hits) {
    stderr.writeln(h);
  }
  stderr.writeln(jsonEncode({'ok': false, 'hits': hits.length}));
  exit(1);
}

String filePathJoin(String repoRootFwd, String relPosix) {
  final sep = Platform.pathSeparator;
  return '$repoRootFwd$sep${relPosix.replaceAll(RegExp('/'), sep)}';
}

bool _skipTracked(String rel, SecretAllowlist allow) {
  if (allow.matchesPath(rel)) return true;
  final norm = rel.replaceAll(RegExp(r'\\'), '/');
  if (rel.endsWith('.lock')) return true;
  if (rel.endsWith('.dll') || rel.endsWith('.dll.track.dill')) return true;
  if (norm.contains('/build/')) return true;
  return false;
}

List<String> _scanText(
  List<String> lines,
  String pseudoPath,
  SecretAllowlist allow,
  List<SecretPattern> patterns,
) {
  final hits = <String>[];

  void checkLine(String raw, String sourceLabel) {
    if (allow.skipLineGlobally(raw)) return;
    for (final sp in patterns) {
      final m = sp.regex.firstMatch(raw);
      if (m != null) {
        if (sp.description == 'Three-part JWT-shaped token' &&
            raw.contains('eyJpc3MiOiJzdXBhYmFzZS1kZW1v')) {
          continue;
        }
        hits.add(
          '${sp.description} @ $pseudoPath ($sourceLabel): ${_trim(raw, 200)}',
        );
      }
    }
    if (!entropySuspicious(raw, allow)) return;
    hits.add(
      'High-entropy substring @ $pseudoPath ($sourceLabel): ${_trim(raw, 200)}',
    );
  }

  for (var i = 0; i < lines.length; i++) {
    checkLine(lines[i], 'line ${i + 1}');
  }

  return hits;
}

bool scanBinaryPath(String rel) => RegExp(
  r'\.(?:png|jpe?g|gif|webp|ico|zip|apk|aab|dmg|dll|exe|pdf)$',
).hasMatch(rel);

bool entropySuspicious(String line, SecretAllowlist allow) {
  if (allow.entropyAllows(line)) return false;
  for (final slice in tokenCandidates(line)) {
    final t = slice.trim();
    if (t.length < 46) continue;
    if (!_printableHeavy(t)) continue;
    final e = _shannon(t);
    if (e >= 4.7) return true;
  }
  return false;
}

Iterable<String> tokenCandidates(String line) sync* {
  final splits = line
      .split(RegExp(r'[^\w+/=\.-]'))
      .where((String e) => e.isNotEmpty);
  for (final s in splits) {
    yield s;
  }
}

bool _printableHeavy(String s) =>
    RegExp(r'^[A-Za-z0-9+/\-_=]+$').hasMatch(s) ||
    RegExp(r'^[a-fA-F0-9]+$').hasMatch(s);

double _shannon(String s) {
  final freq = <int, int>{};
  for (final u in s.codeUnits) {
    freq[u] = (freq[u] ?? 0) + 1;
  }
  var h = 0.0;
  final n = s.length;
  for (final c in freq.values) {
    final p = c / n;
    h -= p * math.log(p) / math.ln2;
  }
  return h;
}

String _trim(String s, int max) => s.length <= max
    ? s
    : '${s.substring(0, max)}… (${s.length - max} more chars)';

class SecretAllowlist {
  SecretAllowlist({
    required this.pathPrefixes,
    required this.lineSkips,
    required this.entropySkips,
  });

  factory SecretAllowlist.load(String raw) {
    final y = loadYaml(raw);
    if (y is! YamlMap) {
      throw StateError('allowlist invalid root');
    }
    final prefixes = <String>{};
    final pp = y['path_prefixes'];
    if (pp is YamlList) {
      for (final e in pp) {
        if (e is YamlMap && e['path_prefix'] != null) {
          prefixes.add(e['path_prefix'].toString());
        }
      }
    }

    final lineSkips = <RegExp>{};
    final ls = y['line_regex_skip'];
    if (ls is YamlList) {
      for (final e in ls) {
        lineSkips.add(RegExp(e.toString(), caseSensitive: false));
      }
    }

    final entropySkips = <String>[];
    final es = y['entropy_skip_substrings'];
    if (es is YamlList) {
      for (final e in es) {
        entropySkips.add(e.toString());
      }
    }

    return SecretAllowlist(
      pathPrefixes: prefixes,
      lineSkips: lineSkips,
      entropySkips: entropySkips,
    );
  }

  final Set<String> pathPrefixes;
  final Set<RegExp> lineSkips;
  final List<String> entropySkips;

  bool matchesPath(String rel) {
    for (final raw in pathPrefixes) {
      final pre = raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
      if (rel == pre || rel.startsWith('$pre/')) return true;
    }
    return false;
  }

  bool skipLineGlobally(String line) => lineSkips.any((r) => r.hasMatch(line));

  bool entropyAllows(String line) {
    for (final s in entropySkips) {
      if (line.contains(s)) return true;
    }
    return false;
  }
}

class SecretPattern {
  SecretPattern(this.regex, {required this.description});

  final RegExp regex;
  final String description;
}

String stderrText(ProcessResult patch) => processOut(patch.stderr).trimRight();

String processOut(dynamic out) =>
    out is String ? out : utf8.decode(out as List<int>);

String _findRepoRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 10; i++) {
    if (File('${dir.path}/supabase/config.toml').existsSync()) {
      return dir.path.replaceAll(RegExp(r'\\'), '/');
    }
    dir = dir.parent;
  }
  return Directory.current.path.replaceAll(RegExp(r'\\'), '/');
}

int _intArg(List<String> args, String name, int def) {
  final i = args.indexOf(name);
  if (i < 0 || i + 1 >= args.length) return def;
  return int.tryParse(args[i + 1]) ?? def;
}
