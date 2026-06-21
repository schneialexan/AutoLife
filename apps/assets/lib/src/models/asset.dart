import 'asset_document.dart';
import 'money.dart';
import 'property_value.dart';

/// A single owned item in the vault. Every field except [id] is optional.
class Asset {
  Asset({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.purchaseDate,
    this.price,
    this.receiptPhotoPath,
    this.productPhotoPath,
    List<AssetDocument>? warrantyDocuments,
    Map<String, PropertyValue>? propertyValues,
  }) : warrantyDocuments = warrantyDocuments ?? <AssetDocument>[],
       propertyValues = propertyValues ?? <String, PropertyValue>{};

  final String id;
  final String? name;
  final DateTime? purchaseDate;
  final Money? price;

  /// Local path to the receipt file. May be an image or a PDF (`.pdf`).
  final String? receiptPhotoPath;

  /// Local path to the product photo (always an image).
  final String? productPhotoPath;

  /// Warranty proofs (PDFs and/or images).
  final List<AssetDocument> warrantyDocuments;

  /// typeId -> typed value; only types the user explicitly added to this asset.
  final Map<String, PropertyValue> propertyValues;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Label shown in lists: name, else the first non-empty property value, else
  /// the "Untitled asset" fallback.
  String get displayLabel {
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    for (final value in propertyValues.values) {
      if (!value.isEmpty) {
        return value.displayString();
      }
    }
    return 'Untitled asset';
  }

  bool get hasName => (name?.trim().isNotEmpty) ?? false;

  /// Whether a receipt file (image or PDF) is attached.
  bool get hasReceipt => (receiptPhotoPath?.isNotEmpty) ?? false;

  /// Whether the attached receipt is a PDF rather than an image.
  bool get receiptIsPdf =>
      hasReceipt && receiptPhotoPath!.toLowerCase().endsWith('.pdf');

  Asset copyWith({
    String? name,
    bool clearName = false,
    DateTime? purchaseDate,
    bool clearPurchaseDate = false,
    Money? price,
    bool clearPrice = false,
    String? receiptPhotoPath,
    bool clearReceiptPhoto = false,
    String? productPhotoPath,
    bool clearProductPhoto = false,
    List<AssetDocument>? warrantyDocuments,
    Map<String, PropertyValue>? propertyValues,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id,
      name: clearName ? null : (name ?? this.name),
      purchaseDate: clearPurchaseDate
          ? null
          : (purchaseDate ?? this.purchaseDate),
      price: clearPrice ? null : (price ?? this.price),
      receiptPhotoPath: clearReceiptPhoto
          ? null
          : (receiptPhotoPath ?? this.receiptPhotoPath),
      productPhotoPath: clearProductPhoto
          ? null
          : (productPhotoPath ?? this.productPhotoPath),
      warrantyDocuments: warrantyDocuments ?? this.warrantyDocuments,
      propertyValues: propertyValues ?? this.propertyValues,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// All local file paths referenced by this asset (receipt + product photo +
  /// Photo property values + warranty docs). Used for cleanup on delete.
  List<String> localFilePaths() {
    final paths = <String>[];
    final receipt = receiptPhotoPath;
    if (receipt != null && receipt.isNotEmpty) {
      paths.add(receipt);
    }
    final product = productPhotoPath;
    if (product != null && product.isNotEmpty) {
      paths.add(product);
    }
    for (final value in propertyValues.values) {
      if (value is PhotoValue && value.path.isNotEmpty) {
        paths.add(value.path);
      }
    }
    for (final doc in warrantyDocuments) {
      if (doc.path.isNotEmpty) {
        paths.add(doc.path);
      }
    }
    return paths;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'purchaseDate': purchaseDate?.toIso8601String(),
    'price': price?.toJson(),
    'receiptPhotoPath': receiptPhotoPath,
    'productPhotoPath': productPhotoPath,
    'warrantyDocuments': warrantyDocuments.map((d) => d.toJson()).toList(),
    'propertyValues': propertyValues.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Asset.fromJson(Map<String, dynamic> json) {
    final rawValues = (json['propertyValues'] as Map?) ?? <String, dynamic>{};
    final values = <String, PropertyValue>{};
    rawValues.forEach((key, value) {
      values[key as String] = PropertyValue.fromJson(
        (value as Map).cast<String, dynamic>(),
      );
    });
    final rawDocs = (json['warrantyDocuments'] as List?) ?? const <dynamic>[];
    final docs = rawDocs
        .map(
          (raw) => AssetDocument.fromJson((raw as Map).cast<String, dynamic>()),
        )
        .toList();
    final rawPrice = json['price'];
    return Asset(
      id: json['id'] as String,
      name: json['name'] as String?,
      purchaseDate: json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
      price: rawPrice == null
          ? null
          : Money.fromJson((rawPrice as Map).cast<String, dynamic>()),
      receiptPhotoPath: json['receiptPhotoPath'] as String?,
      productPhotoPath: json['productPhotoPath'] as String?,
      warrantyDocuments: docs,
      propertyValues: values,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
