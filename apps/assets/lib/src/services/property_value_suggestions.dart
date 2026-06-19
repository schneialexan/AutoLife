import '../models/asset.dart';
import '../models/property_value.dart';
import '../models/value_kind.dart';

/// Produces autocomplete suggestions for Text category fields, drawn from
/// values already entered for the same type on other assets.
class PropertyValueSuggestions {
  const PropertyValueSuggestions();

  List<String> suggestionsFor({
    required String typeId,
    required ValueKind valueKind,
    required List<Asset> assets,
    String? excludeAssetId,
  }) {
    if (valueKind != ValueKind.text) {
      return const <String>[];
    }
    final seen = <String>{};
    final result = <String>[];
    for (final asset in assets) {
      if (asset.id == excludeAssetId) {
        continue;
      }
      final value = asset.propertyValues[typeId];
      if (value is TextValue) {
        final text = value.value.trim();
        if (text.isNotEmpty && seen.add(text.toLowerCase())) {
          result.add(text);
        }
      }
    }
    result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }
}
