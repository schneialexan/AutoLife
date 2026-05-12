import 'package:autolife_core/autolife_core.dart';

class QuickAddParseResult {
  const QuickAddParseResult({
    required this.title,
    this.dueAt,
    this.listSlug,
    this.priority = TaskPriority.medium,
    this.importance = false,
    this.assigneeHint,
  });

  final String title;
  final DateTime? dueAt;
  /// Lowercase slug after `#`, e.g. `grocery`
  final String? listSlug;
  final TaskPriority priority;
  final bool importance;
  /// Raw `@token` without @
  final String? assigneeHint;
}

/// Natural-language quick-add (subset of grammar from phase 3.3 rewrite).
class QuickAddParser {
  const QuickAddParser();

  QuickAddParseResult parse(String raw, {DateTime? now}) {
    final clock = now ?? DateTime.now();
    var s = raw.trim();
    if (s.isEmpty) {
      return const QuickAddParseResult(title: 'Untitled');
    }

    TaskPriority priority = TaskPriority.medium;
    if (s.contains('!!!')) {
      priority = TaskPriority.high;
      s = s.replaceAll('!!!', '').trim();
    } else if (s.contains('!!')) {
      priority = TaskPriority.medium;
      s = s.replaceAll('!!', '').trim();
    } else if (RegExp(r'(?<!\!)!\b').hasMatch(s) || s.endsWith('!')) {
      // single ! for low priority if not part of !!
      s = s.replaceFirst('!', '').trim();
      priority = TaskPriority.low;
    }

    var importance = false;
    if (s.contains('*')) {
      importance = true;
      s = s.split('*').join('').trim();
    }

    String? listSlug;
    final hash = RegExp(r'#(\w+)');
    final hm = hash.firstMatch(s);
    if (hm != null) {
      listSlug = hm.group(1)!.toLowerCase();
      s = s.replaceFirst(hash, '').trim();
    }

    String? assigneeHint;
    final at = RegExp(r'@(\w+)');
    final am = at.firstMatch(s);
    if (am != null) {
      assigneeHint = am.group(1);
      s = s.replaceFirst(at, '').trim();
    }

    DateTime? dueAt;
    final lower = s.toLowerCase();
    if (lower.contains('tomorrow')) {
      final base = DateTime(clock.year, clock.month, clock.day);
      final tomorrow = base.add(const Duration(days: 1));
      dueAt = tomorrow;
      s = s.replaceAll(RegExp(r'tomorrow', caseSensitive: false), '').trim();
    } else if (lower.contains('today') || lower.contains('/today')) {
      dueAt = DateTime(clock.year, clock.month, clock.day);
      s = s
          .replaceAll(RegExp(r'/today', caseSensitive: false), '')
          .replaceAll(RegExp(r'\btoday\b', caseSensitive: false), '')
          .trim();
    }

    final timeM = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?', caseSensitive: false)
        .firstMatch(s);
    if (timeM != null && dueAt != null) {
      var h = int.parse(timeM.group(1)!);
      final min = timeM.group(2) != null ? int.parse(timeM.group(2)!) : 0;
      final ap = timeM.group(3)?.toLowerCase();
      if (ap == 'pm' && h < 12) h += 12;
      if (ap == 'am' && h == 12) h = 0;
      dueAt = DateTime(dueAt.year, dueAt.month, dueAt.day, h, min);
      s = s.replaceFirst(timeM.group(0)!, '').trim();
    }

    var title = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (title.isEmpty) title = 'Untitled';

    return QuickAddParseResult(
      title: title,
      dueAt: dueAt?.toUtc(),
      listSlug: listSlug,
      priority: priority,
      importance: importance,
      assigneeHint: assigneeHint,
    );
  }
}
