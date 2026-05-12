import 'dart:convert';

import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/shell_providers.dart';

final omnibarSearchServiceProvider = Provider<OmnibarSearchService>((ref) {
  final db = ref.watch(autolifeDatabaseProvider);
  final tenant = ref.watch(shellTenantIdProvider);
  return OmnibarSearchService(db: db, tenantId: tenant);
});

/// Phase 3.1 omnibar: scans cached `system_event` rows (local substring match).
///
/// FTS + Supabase remote fan-out ship with phase 3.14 per plan risks section.
class OmnibarSearchService {
  OmnibarSearchService({
    required AutolifeDatabase db,
    required this.tenantId,
  }) : _db = db;

  final String tenantId;

  final AutolifeDatabase _db;

  static const int _minChars = 2;
  static const int _cap = 25;

  Future<List<OmnibarSearchResult>> search(String rawQuery) async {
    final q = rawQuery.trim().toLowerCase();
    if (q.length < _minChars) return const [];

    final rows = await (_db.select(_db.systemEventCache)
          ..where((t) => t.tenantId.equals(tenantId)))
        .get();

    final out = <OmnibarSearchResult>[];
    for (final row in rows) {
      Map<String, dynamic> payload;
      try {
        payload =
            jsonDecode(row.payloadJson) as Map<String, dynamic>? ?? const {};
      } catch (_) {
        payload = const {};
      }
      final title = payload['title'] as String? ?? '';
      final haystack =
          '${row.type} ${row.module} $title'.toLowerCase();
      if (!haystack.contains(q)) continue;

      out.add(
        OmnibarSearchResult(
          moduleId: row.module,
          title: title.isEmpty ? row.type : title,
          subtitle: '${row.module} · ${row.type}',
          entityId: row.id,
          rank: out.length.toDouble(),
        ),
      );
      if (out.length >= _cap) break;
    }
    return out;
  }
}
