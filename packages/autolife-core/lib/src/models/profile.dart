class Profile {
  const Profile({
    required this.id,
    required this.familyId,
    required this.displayName,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String familyId;
  final String displayName;
  final String role;
  final DateTime createdAt;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      displayName: json['display_name'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'family_id': familyId,
        'display_name': displayName,
        'role': role,
        'created_at': createdAt.toIso8601String(),
      };
}
