import 'dart:convert';

/// How the dashboard host handles viewport overflow / paging (phase 3.1.5.1).
enum DashboardOverflowMode {
  autoFit,

  /// Fixed row heights × heightUnits in a vertical list.
  scrollVertical,

  /// Vertical PageView snapping by viewport/page slice.
  scrollSnap,

  /// Horizontal pager; [`boardBreaks`] marks row indices where a new board starts.
  boards,
}

/// Per-scope presentation settings persisted with [DashboardLayout].
class DashboardPresentation {
  const DashboardPresentation({
    this.mode = DashboardOverflowMode.autoFit,
    this.boardBreaks = const [],
  });

  /// Default: viewport-flex with scroll fallback inside autoFit path.
  static const DashboardPresentation defaultPresentation =
      DashboardPresentation();

  final DashboardOverflowMode mode;

  /// Row indices (\>= 1) where a new board begins; board 0 always starts at row 0.
  /// Example: `[3]` → rows 0–2 on board A, rows 3+ on board B.
  final List<int> boardBreaks;

  DashboardPresentation copyWith({
    DashboardOverflowMode? mode,
    List<int>? boardBreaks,
  }) {
    return DashboardPresentation(
      mode: mode ?? this.mode,
      boardBreaks: boardBreaks ?? this.boardBreaks,
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'board_breaks': boardBreaks,
      };

  factory DashboardPresentation.fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return defaultPresentation;
    final modeName = raw['mode'] as String? ?? 'autoFit';
    final mode = DashboardOverflowMode.values.firstWhere(
      (e) => e.name == modeName,
      orElse: () => DashboardOverflowMode.autoFit,
    );
    final breaksRaw =
        raw['board_breaks'] as List<dynamic>? ?? raw['boardBreaks'] as List<dynamic>? ?? [];
    final breaks =
        breaksRaw.map((e) => (e as num).toInt()).where((x) => x >= 1).toList()
          ..sort();
    return DashboardPresentation(mode: mode, boardBreaks: breaks);
  }

  /// Drops invalid/out-of-range break indices against [rowCount].
  DashboardPresentation normalized(int rowCount) {
    if (rowCount <= 1 || mode != DashboardOverflowMode.boards) {
      return DashboardPresentation(mode: mode, boardBreaks: []);
    }
    final maxStart = rowCount - 1;
    final uniq = boardBreaks.toSet().where((x) => x >= 1 && x <= maxStart).toList()
      ..sort();
    return DashboardPresentation(mode: mode, boardBreaks: uniq);
  }

  @override
  bool operator ==(Object other) {
    return other is DashboardPresentation &&
        other.mode == mode &&
        json.encode(other.boardBreaks) == json.encode(boardBreaks);
  }

  @override
  int get hashCode => Object.hash(mode, Object.hashAll(boardBreaks));

  /// Inclusive slice `[start,end)` row indices per board given [rowCount].
  List<List<int>> boardRowSlices(int rowCount) {
    if (rowCount <= 0) return [];
    final b = normalized(rowCount).boardBreaks;
    if (b.isEmpty || mode != DashboardOverflowMode.boards) {
      return [List<int>.generate(rowCount, (i) => i)];
    }
    final slices = <List<int>>[];
    var start = 0;
    for (final breakAt in b) {
      final end = breakAt.clamp(0, rowCount);
      if (end <= start) continue;
      slices.add(List<int>.generate(end - start, (j) => start + j));
      start = end;
    }
    if (start < rowCount) {
      slices.add(List<int>.generate(rowCount - start, (j) => start + j));
    }
    return slices.isEmpty ? [List<int>.generate(rowCount, (i) => i)] : slices;
  }
}
