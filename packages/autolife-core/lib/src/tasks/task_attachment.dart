import 'package:meta/meta.dart';

/// File attachment metadata for a task (mirrors calendar attachment shape).
@immutable
class TaskAttachment {
  const TaskAttachment({
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

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      storagePath: json['storage_path'] as String?,
      localUri: json['local_uri'] as String?,
      mimeType: json['mime_type'] as String?,
      filename: json['filename'] as String?,
      sizeBytes: (json['size_bytes'] as num?)?.toInt(),
    );
  }
}
