import 'package:meta/meta.dart';

/// Guest / attendee row (family profile or external contact).
@immutable
class CalendarAttendee {
  const CalendarAttendee({
    this.profileId,
    this.email,
    this.displayName,
  });

  final String? profileId;
  final String? email;
  final String? displayName;

  Map<String, dynamic> toJson() => {
    if (profileId != null) 'profile_id': profileId,
    if (email != null && email!.isNotEmpty) 'email': email,
    if (displayName != null && displayName!.isNotEmpty) 'display_name': displayName,
  };

  factory CalendarAttendee.fromJson(Map<String, dynamic> json) {
    return CalendarAttendee(
      profileId: json['profile_id'] as String?,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
    );
  }
}
