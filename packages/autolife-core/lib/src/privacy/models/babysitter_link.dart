import 'babysitter_scope_toggles.dart';

/// Public.babysitter_links row as returned by PostgREST (no raw token).
class BabysitterLink {
  BabysitterLink({
    required this.id,
    required this.familyId,
    required this.label,
    required this.toggles,
    required this.createdBy,
    required this.expiresAt,
    required this.revokedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String familyId;
  final String label;
  final BabysitterScopeToggles toggles;
  final String createdBy;
  final DateTime expiresAt;
  final DateTime? revokedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BabysitterLink.fromMap(Map<String, dynamic> m) {
    return BabysitterLink(
      id: m['id'] as String,
      familyId: m['family_id'] as String,
      label: (m['label'] as String?) ?? '',
      toggles: BabysitterScopeToggles(
        wifiCredentials: m['wifi_credentials'] as bool? ?? false,
        emergencyContacts: m['emergency_contacts'] as bool? ?? false,
        allergies: m['allergies'] as bool? ?? false,
        locations: m['locations'] as bool? ?? false,
      ),
      createdBy: m['created_by'] as String,
      expiresAt: DateTime.parse(m['expires_at'] as String),
      revokedAt: m['revoked_at'] != null
          ? DateTime.parse(m['revoked_at'] as String)
          : null,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
    );
  }
}

enum BabysitterScopeStatus { ok, invalid, expired, revoked }

/// Result of `public.babysitter_scope` via RPC.
class BabysitterScopeResolution {
  BabysitterScopeResolution({
    required this.status,
    this.familyId,
    this.linkId,
    this.resources = const [],
  });

  final BabysitterScopeStatus status;
  final String? familyId;
  final String? linkId;
  final List<String> resources;

  factory BabysitterScopeResolution.fromJson(Map<String, dynamic> j) {
    final s = j['status'] as String? ?? 'invalid';
    final status = switch (s) {
      'ok' => BabysitterScopeStatus.ok,
      'expired' => BabysitterScopeStatus.expired,
      'revoked' => BabysitterScopeStatus.revoked,
      _ => BabysitterScopeStatus.invalid,
    };
    final raw = j['resources'];
    final resources = <String>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is String) resources.add(e);
      }
    }
    return BabysitterScopeResolution(
      status: status,
      familyId: j['family_id'] as String?,
      linkId: j['link_id'] as String?,
      resources: resources,
    );
  }
}

/// Returned once when a link is minted; callers must persist [rawToken] for sharing.
class CreatedBabysitterLink {
  CreatedBabysitterLink({required this.link, required this.rawToken});

  final BabysitterLink link;
  final String rawToken;
}
