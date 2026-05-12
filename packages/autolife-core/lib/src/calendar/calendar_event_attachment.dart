import 'package:meta/meta.dart';

/// File or image reference for a calendar event (paths are client-local until uploaded).
@immutable
class CalendarEventAttachment {
  const CalendarEventAttachment({
    this.storagePath,
    this.localUri,
    this.mimeType,
    this.filename,
    this.sizeBytes,
  });

  final String? storagePath;
  final String? localUri;
  final String? mimeType;
  final String? filename;
  final int? sizeBytes;

  Map<String, dynamic> toJson() => {
    if (storagePath != null) 'storage_path': storagePath,
    if (localUri != null) 'local_uri': localUri,
    if (mimeType != null) 'mime_type': mimeType,
    if (filename != null) 'filename': filename,
    if (sizeBytes != null) 'size_bytes': sizeBytes,
  };

  factory CalendarEventAttachment.fromJson(Map<String, dynamic> json) {
    return CalendarEventAttachment(
      storagePath: json['storage_path'] as String?,
      localUri: json['local_uri'] as String?,
      mimeType: json['mime_type'] as String?,
      filename: json['filename'] as String?,
      sizeBytes: (json['size_bytes'] as num?)?.toInt(),
    );
  }
}
