import 'package:meta/meta.dart';

/// Hyperlink attached to a calendar event (meet link, docs, etc.).
@immutable
class CalendarEventLink {
  const CalendarEventLink({
    required this.url,
    this.label,
  });

  final String url;
  final String? label;

  Map<String, dynamic> toJson() => {
    'url': url,
    if (label != null && label!.isNotEmpty) 'label': label,
  };

  factory CalendarEventLink.fromJson(Map<String, dynamic> json) {
    return CalendarEventLink(
      url: json['url'] as String? ?? '',
      label: json['label'] as String?,
    );
  }
}
