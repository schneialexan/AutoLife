import 'package:flutter/material.dart';

/// A single entry in the curated icon/emoji catalog.
class CategoryIconSpec {
  const CategoryIconSpec.material(this.key, this.label, IconData icon)
    : iconData = icon,
      emoji = null;

  const CategoryIconSpec.emoji(this.key, this.label, String glyph)
    : iconData = null,
      emoji = glyph;

  /// Namespaced storage key, e.g. `icon:tag` or `emoji:1f3e0`.
  final String key;
  final String label;
  final IconData? iconData;
  final String? emoji;

  bool get isEmoji => emoji != null;
}

/// Predefined icon + emoji catalog. No free-text emoji or custom uploads, so a
/// type renders identically on every device.
class CategoryIcons {
  const CategoryIcons._();

  static const String defaultIcon = 'icon:tag';

  static const List<CategoryIconSpec> materialIcons = <CategoryIconSpec>[
    CategoryIconSpec.material('icon:tag', 'Tag', Icons.sell_outlined),
    CategoryIconSpec.material(
      'icon:category',
      'Category',
      Icons.category_outlined,
    ),
    CategoryIconSpec.material('icon:label', 'Label', Icons.label_outline),
    CategoryIconSpec.material('icon:store', 'Store', Icons.storefront_outlined),
    CategoryIconSpec.material('icon:home', 'Home', Icons.home_outlined),
    CategoryIconSpec.material('icon:room', 'Room', Icons.meeting_room_outlined),
    CategoryIconSpec.material('icon:scale', 'Weight', Icons.scale_outlined),
    CategoryIconSpec.material('icon:cube', 'Model', Icons.view_in_ar_outlined),
    CategoryIconSpec.material(
      'icon:devices',
      'Devices',
      Icons.devices_outlined,
    ),
    CategoryIconSpec.material('icon:bolt', 'Power', Icons.bolt_outlined),
    CategoryIconSpec.material('icon:build', 'Tools', Icons.build_outlined),
    CategoryIconSpec.material(
      'icon:kitchen',
      'Kitchen',
      Icons.kitchen_outlined,
    ),
    CategoryIconSpec.material('icon:chair', 'Furniture', Icons.chair_outlined),
    CategoryIconSpec.material(
      'icon:checkroom',
      'Apparel',
      Icons.checkroom_outlined,
    ),
    CategoryIconSpec.material(
      'icon:directions_car',
      'Vehicle',
      Icons.directions_car_outlined,
    ),
    CategoryIconSpec.material('icon:watch', 'Watch', Icons.watch_outlined),
    CategoryIconSpec.material(
      'icon:diamond',
      'Valuables',
      Icons.diamond_outlined,
    ),
    CategoryIconSpec.material(
      'icon:verified',
      'Condition',
      Icons.verified_outlined,
    ),
    CategoryIconSpec.material('icon:calendar', 'Date', Icons.event_outlined),
    CategoryIconSpec.material('icon:numbers', 'Number', Icons.numbers_outlined),
  ];

  static const List<CategoryIconSpec> emojis = <CategoryIconSpec>[
    CategoryIconSpec.emoji('emoji:1f3f7', 'Label', '\u{1F3F7}'),
    CategoryIconSpec.emoji('emoji:1f3e0', 'Home', '\u{1F3E0}'),
    CategoryIconSpec.emoji('emoji:1f3ec', 'Store', '\u{1F3EC}'),
    CategoryIconSpec.emoji('emoji:2696', 'Scale', '\u{2696}\u{FE0F}'),
    CategoryIconSpec.emoji('emoji:1f4e6', 'Box', '\u{1F4E6}'),
    CategoryIconSpec.emoji('emoji:1f4f1', 'Phone', '\u{1F4F1}'),
    CategoryIconSpec.emoji('emoji:1f4bb', 'Laptop', '\u{1F4BB}'),
    CategoryIconSpec.emoji('emoji:1f527', 'Tools', '\u{1F527}'),
    CategoryIconSpec.emoji('emoji:1f373', 'Kitchen', '\u{1F373}'),
    CategoryIconSpec.emoji('emoji:1fa91', 'Chair', '\u{1FA91}'),
    CategoryIconSpec.emoji('emoji:1f455', 'Apparel', '\u{1F455}'),
    CategoryIconSpec.emoji('emoji:1f697', 'Car', '\u{1F697}'),
    CategoryIconSpec.emoji('emoji:231a', 'Watch', '\u{231A}'),
    CategoryIconSpec.emoji('emoji:1f48e', 'Gem', '\u{1F48E}'),
    CategoryIconSpec.emoji('emoji:2705', 'Check', '\u{2705}'),
    CategoryIconSpec.emoji('emoji:1f4c5', 'Date', '\u{1F4C5}'),
    CategoryIconSpec.emoji('emoji:1f3a8', 'Art', '\u{1F3A8}'),
    CategoryIconSpec.emoji('emoji:1f4da', 'Books', '\u{1F4DA}'),
    CategoryIconSpec.emoji('emoji:1f6cb', 'Furniture', '\u{1F6CB}\u{FE0F}'),
    CategoryIconSpec.emoji('emoji:26a1', 'Power', '\u{26A1}'),
  ];

  static List<CategoryIconSpec> get all => <CategoryIconSpec>[
    ...materialIcons,
    ...emojis,
  ];

  static CategoryIconSpec specFor(String key) {
    for (final spec in all) {
      if (spec.key == key) {
        return spec;
      }
    }
    return all.firstWhere((s) => s.key == defaultIcon);
  }
}
