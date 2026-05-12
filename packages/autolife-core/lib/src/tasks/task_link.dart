import 'package:meta/meta.dart';

@immutable
class TaskLink {
  const TaskLink({required this.url, this.label});

  final String url;
  final String? label;

  Map<String, dynamic> toJson() => {
    'url': url,
    if (label != null && label!.isNotEmpty) 'label': label,
  };

  factory TaskLink.fromJson(Map<String, dynamic> json) {
    return TaskLink(
      url: json['url'] as String? ?? '',
      label: json['label'] as String?,
    );
  }
}
