/// A warranty document (PDF or image) attached to an asset.
///
/// [path] is the local file path inside app-private storage; [name] is the
/// original filename shown to the user.
class AssetDocument {
  const AssetDocument({required this.path, required this.name});

  final String path;
  final String name;

  /// Whether the document is a PDF (by file extension).
  bool get isPdf => path.toLowerCase().endsWith('.pdf');

  Map<String, dynamic> toJson() => <String, dynamic>{
    'path': path,
    'name': name,
  };

  factory AssetDocument.fromJson(Map<String, dynamic> json) {
    return AssetDocument(
      path: json['path'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
