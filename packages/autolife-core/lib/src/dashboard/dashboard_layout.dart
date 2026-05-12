import 'dart:convert';

import 'dashboard_row.dart';
import 'dashboard_scope.dart';
import 'dashboard_size.dart';
import 'dashboard_tile.dart';
import 'dashboard_adaptive_mode.dart';
import 'dashboard_presentation.dart';

/// Single placement in a v1 [DashboardLayout] (legacy staggered grid slots).
class DashboardSlot {
  const DashboardSlot({
    required this.widgetId,
    required this.requestedSize,
  });

  final String widgetId;
  final DashboardSize requestedSize;

  Map<String, dynamic> toJson() => {
        'widget_id': widgetId,
        'size': requestedSize.name,
      };

  static DashboardSlot fromJson(Map<String, dynamic> json) {
    final raw = json['widget_id'] as String? ?? json['widgetId'] as String?;
    final sizeRaw =
        json['size'] as String? ?? json['requested_size'] as String?;
    if (raw == null || sizeRaw == null) {
      throw FormatException('Invalid DashboardSlot json: $json');
    }
    return DashboardSlot(
      widgetId: raw,
      requestedSize: DashboardSize.values.firstWhere(
        (e) => e.name == sizeRaw,
        orElse: () => DashboardSize.m,
      ),
    );
  }
}

/// Ordered dashboard placements for [DashboardHost].
///
/// Schema **1**: flat [slots] only.
/// Schema **2**: [base] rows + sparse [rowOverrides] keyed by [DashboardScope.cacheKey].
class DashboardLayout {
  const DashboardLayout({
    this.schemaVersion = 1,
    this.slots = const [],
    this.base = const [],
    this.rowOverrides = const {},
    this.basePresentation = DashboardPresentation.defaultPresentation,
    this.presentationOverrides = const {},
  });

  /// Layout schema (`1` = legacy slots, `2` = rows + overrides).
  final int schemaVersion;

  /// v1 slot list (ignored when [schemaVersion] >= 2).
  final List<DashboardSlot> slots;

  /// v2 canonical rows.
  final List<DashboardRow> base;

  /// v2 sparse overrides `"formFactor:adaptive"` → row list.
  final Map<String, List<DashboardRow>> rowOverrides;

  /// v2 canonical presentation / overflow behaviour.
  final DashboardPresentation basePresentation;

  /// v2 `"formFactor:adaptive"` → presentation override.
  final Map<String, DashboardPresentation> presentationOverrides;

  bool get isV2 => schemaVersion >= 2;

  /// Rows to render for the given [scope] (applies override resolution).
  List<DashboardRow> resolveRows(DashboardScope scope) {
    if (!isV2) {
      return migrateSlotsToRows(slots);
    }
    final key = scope.cacheKey;
    final anyKey = DashboardScope(
      formFactor: scope.formFactor,
      adaptive: DashboardAdaptiveMode.anyTime,
    ).cacheKey;
    final override = rowOverrides[key] ?? rowOverrides[anyKey];
    final source = override ?? base;
    return cloneRows(source);
  }

  /// Resolved display mode / board breaks for [scope].
  DashboardPresentation resolvePresentation(DashboardScope scope) {
    if (!isV2) {
      return DashboardPresentation.defaultPresentation;
    }
    final key = scope.cacheKey;
    final anyKey = DashboardScope(
      formFactor: scope.formFactor,
      adaptive: DashboardAdaptiveMode.anyTime,
    ).cacheKey;
    final o = presentationOverrides[key] ??
        presentationOverrides[anyKey] ??
        basePresentation;
    final rc = resolveRows(scope).length;
    return o.normalized(rc);
  }

  static List<DashboardRow> cloneRows(List<DashboardRow> rows) {
    return rows
        .map(
          (r) => DashboardRow(
            heightUnits: r.heightUnits,
            minHeightPx: r.minHeightPx,
            tiles: r.tiles
                .map(
                  (t) => DashboardTile(
                    widgetId: t.widgetId,
                    widthUnits: t.widthUnits,
                    spanRows: t.spanRows,
                    minHeightPx: t.minHeightPx,
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  /// v1 `slots` → v2 row packing (preserves ordering).
  static List<DashboardRow> migrateSlotsToRows(List<DashboardSlot> slots) {
    final rows = <DashboardRow>[];
    var buffer = <DashboardTile>[];
    var bufW = 0;

    void flush({int heightUnits = 1}) {
      if (buffer.isEmpty) return;
      rows.add(
        DashboardRow(heightUnits: heightUnits, tiles: List<DashboardTile>.from(buffer)),
      );
      buffer = [];
      bufW = 0;
    }

    for (final s in slots) {
      switch (s.requestedSize) {
        case DashboardSize.xl:
          flush();
          rows.add(
            DashboardRow(
              heightUnits: 1,
              tiles: [DashboardTile(widgetId: s.widgetId, widthUnits: 6)],
            ),
          );
          break;
        case DashboardSize.l:
          flush();
          rows.add(
            DashboardRow(
              heightUnits: 2,
              tiles: [DashboardTile(widgetId: s.widgetId, widthUnits: 6)],
            ),
          );
          break;
        case DashboardSize.m:
          if (bufW + 3 > 6) flush();
          buffer.add(DashboardTile(widgetId: s.widgetId, widthUnits: 3));
          bufW += 3;
          if (bufW == 6) flush();
          break;
        case DashboardSize.s:
          if (bufW + 2 > 6) flush();
          buffer.add(DashboardTile(widgetId: s.widgetId, widthUnits: 2));
          bufW += 2;
          if (bufW == 6) flush();
          break;
      }
    }
    flush();
    return rows;
  }

  /// Ensure a v2 instance (upgrades v1 in-memory).
  DashboardLayout migrateToV2() {
    if (isV2) return this;
    return DashboardLayout(
      schemaVersion: 2,
      base: migrateSlotsToRows(slots),
      basePresentation: basePresentation,
      presentationOverrides: presentationOverrides,
    );
  }

  /// Mutates working document for edit-mode saves (all scopes vs single scope).
  DashboardLayout withRowsForScope({
    required List<DashboardRow> rows,
    required DashboardScope scope,
    required bool editAllScopes,
  }) {
    final v2 = migrateToV2();
    final cloned = cloneRows(rows);
    if (editAllScopes) {
      final prunedRows = pruneRedundantOverrides(cloned, v2.rowOverrides);
      return DashboardLayout(
        schemaVersion: 2,
        base: cloned,
        rowOverrides: prunedRows,
        basePresentation: v2.basePresentation,
        presentationOverrides: pruneRedundantPresentationOverrides(
          v2.basePresentation,
          v2.presentationOverrides,
        ),
      );
    }
    final next = Map<String, List<DashboardRow>>.from(v2.rowOverrides);
    next[scope.cacheKey] = cloned;
    return DashboardLayout(
      schemaVersion: 2,
      base: v2.base,
      rowOverrides: next,
      basePresentation: v2.basePresentation,
      presentationOverrides: v2.presentationOverrides,
    );
  }

  DashboardLayout withPresentationForScope({
    required DashboardPresentation presentation,
    required DashboardScope scope,
    required bool editAllScopes,
    int? rowCountForNormalization,
  }) {
    final v2 = migrateToV2();
    final rc = rowCountForNormalization ?? resolveRows(scope).length;
    final norm = presentation.normalized(rc);
    if (editAllScopes) {
      return DashboardLayout(
        schemaVersion: 2,
        base: v2.base,
        rowOverrides: v2.rowOverrides,
        basePresentation: norm,
        presentationOverrides:
            pruneRedundantPresentationOverrides(norm, v2.presentationOverrides),
      );
    }
    final nextPres = Map<String, DashboardPresentation>.from(
      v2.presentationOverrides,
    );
    nextPres[scope.cacheKey] = norm;
    return DashboardLayout(
      schemaVersion: 2,
      base: v2.base,
      rowOverrides: v2.rowOverrides,
      basePresentation: v2.basePresentation,
      presentationOverrides: nextPres,
    );
  }

  Map<String, dynamic> toJson() {
    if (isV2) {
      final m = <String, dynamic>{
        'schema': schemaVersion,
        'base': base.map((r) => r.toJson()).toList(),
        'overrides': rowOverrides.map(
          (k, v) => MapEntry(k, v.map((r) => r.toJson()).toList()),
        ),
      };
      final def = DashboardPresentation.defaultPresentation;
      if (basePresentation != def) {
        m['presentation'] = basePresentation.toJson();
      }
      if (presentationOverrides.isNotEmpty) {
        m['presentation_overrides'] = presentationOverrides.map(
          (k, v) => MapEntry(k, v.toJson()),
        );
      }
      return m;
    }
    return {
      'schema': schemaVersion,
      'slots': slots.map((s) => s.toJson()).toList(),
    };
  }

  factory DashboardLayout.fromJson(Map<String, dynamic> json) {
    final schema = json['schema'] as int? ?? json['schemaVersion'] as int? ?? 1;
    if (schema >= 2) {
      final baseRaw = json['base'] as List<dynamic>? ?? const [];
      final base = baseRaw
          .map((e) => DashboardRow.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final ovRaw = json['overrides'] as Map<String, dynamic>? ??
          json['rowOverrides'] as Map<String, dynamic>? ??
          const {};
      final overrides = <String, List<DashboardRow>>{};
      for (final e in ovRaw.entries) {
        final list = (e.value as List<dynamic>)
            .map((x) => DashboardRow.fromJson(Map<String, dynamic>.from(x as Map)))
            .toList();
        overrides[e.key] = list;
      }
      final bpRaw =
          json['presentation'] ?? json['basePresentation'];
      final basePresentation = bpRaw is Map<String, dynamic>
          ? DashboardPresentation.fromJson(bpRaw)
          : DashboardPresentation.defaultPresentation;
      final poRaw =
          json['presentation_overrides'] ??
              json['presentationOverrides'];
      final presOv = <String, DashboardPresentation>{};
      if (poRaw is Map<String, dynamic>) {
        for (final e in poRaw.entries) {
          final v = e.value;
          if (v is Map<String, dynamic>) {
            presOv[e.key] = DashboardPresentation.fromJson(v);
          }
        }
      }
      return DashboardLayout(
        schemaVersion: schema,
        base: base,
        rowOverrides: overrides,
        basePresentation: basePresentation,
        presentationOverrides: presOv,
      );
    }
    final slotsRaw = json['slots'] as List<dynamic>? ??
        json['widgets'] as List<dynamic>? ??
        const [];
    final slots = slotsRaw
        .map((e) => DashboardSlot.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return DashboardLayout(schemaVersion: schema, slots: slots);
  }

  DashboardLayout copyWith({
    int? schemaVersion,
    List<DashboardSlot>? slots,
    List<DashboardRow>? base,
    Map<String, List<DashboardRow>>? rowOverrides,
    DashboardPresentation? basePresentation,
    Map<String, DashboardPresentation>? presentationOverrides,
  }) {
    return DashboardLayout(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      slots: slots ?? this.slots,
      base: base ?? this.base,
      rowOverrides: rowOverrides ?? this.rowOverrides,
      basePresentation: basePresentation ?? this.basePresentation,
      presentationOverrides: presentationOverrides ?? this.presentationOverrides,
    );
  }

  /// Drops override entries whose payload equals [base] rows (JSON equality).
  static Map<String, List<DashboardRow>> pruneRedundantOverrides(
    List<DashboardRow> base,
    Map<String, List<DashboardRow>> overrides,
  ) {
    final baseEnc = json.encode(base.map((r) => r.toJson()).toList());
    final out = <String, List<DashboardRow>>{};
    for (final e in overrides.entries) {
      final enc = json.encode(e.value.map((r) => r.toJson()).toList());
      if (enc != baseEnc) {
        out[e.key] = e.value;
      }
    }
    return out;
  }

  /// Drops presentation override entries identical to [basePresentation].
  static Map<String, DashboardPresentation> pruneRedundantPresentationOverrides(
    DashboardPresentation basePresentation,
    Map<String, DashboardPresentation> overrides,
  ) {
    final baseEnc = json.encode(basePresentation.toJson());
    final out = <String, DashboardPresentation>{};
    for (final e in overrides.entries) {
      if (json.encode(e.value.toJson()) != baseEnc) {
        out[e.key] = e.value;
      }
    }
    return out;
  }
}
