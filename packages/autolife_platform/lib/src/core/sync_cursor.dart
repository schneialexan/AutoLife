/// Per-module pull cursor. Pages on the **server-assigned** `server_updated_at`
/// (DB trigger `now()`), never the client clock, so clock skew can't drop or
/// duplicate records.
class SyncCursor {
  const SyncCursor({required this.moduleId, this.lastServerUpdatedAt});

  final String moduleId;
  final DateTime? lastServerUpdatedAt;

  SyncCursor advancedTo(DateTime candidate) {
    final current = lastServerUpdatedAt;
    if (current == null || candidate.isAfter(current)) {
      return SyncCursor(moduleId: moduleId, lastServerUpdatedAt: candidate);
    }
    return this;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'moduleId': moduleId,
    'lastServerUpdatedAt': lastServerUpdatedAt?.toIso8601String(),
  };

  factory SyncCursor.fromJson(Map<String, dynamic> json) {
    final raw = json['lastServerUpdatedAt'];
    return SyncCursor(
      moduleId: json['moduleId'] as String,
      lastServerUpdatedAt: raw == null ? null : DateTime.parse(raw as String),
    );
  }
}
