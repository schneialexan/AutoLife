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
    CategoryIconSpec.material(
      'icon:laptop',
      'Laptop Computer',
      Icons.computer_outlined,
    ),
    CategoryIconSpec.material(
      'icon:phone',
      'Phone Mobile',
      Icons.phone_android_outlined,
    ),
    CategoryIconSpec.material(
      'icon:headphones',
      'Headphones Audio',
      Icons.headphones_outlined,
    ),
    CategoryIconSpec.material(
      'icon:camera',
      'Camera Photo',
      Icons.camera_alt_outlined,
    ),
    CategoryIconSpec.material('icon:tv', 'TV Television', Icons.tv_outlined),
    CategoryIconSpec.material(
      'icon:speaker',
      'Speaker Sound',
      Icons.speaker_outlined,
    ),
    CategoryIconSpec.material(
      'icon:console',
      'Game Console',
      Icons.sports_esports_outlined,
    ),
    CategoryIconSpec.material(
      'icon:router',
      'Router Network',
      Icons.router_outlined,
    ),
    CategoryIconSpec.material('icon:printer', 'Printer', Icons.print_outlined),
    CategoryIconSpec.material(
      'icon:keyboard',
      'Keyboard',
      Icons.keyboard_outlined,
    ),
    CategoryIconSpec.material(
      'icon:memory',
      'Memory Storage Chip',
      Icons.memory_outlined,
    ),
    CategoryIconSpec.material(
      'icon:lightbulb',
      'Lightbulb Lighting',
      Icons.lightbulb_outline,
    ),
    CategoryIconSpec.material(
      'icon:handyman',
      'Handyman Repair',
      Icons.handyman_outlined,
    ),
    CategoryIconSpec.material('icon:yard', 'Yard Garden', Icons.yard_outlined),
    CategoryIconSpec.material(
      'icon:florist',
      'Plant Flower',
      Icons.local_florist_outlined,
    ),
    CategoryIconSpec.material('icon:pets', 'Pets Animals', Icons.pets_outlined),
    CategoryIconSpec.material(
      'icon:bike',
      'Bicycle Bike',
      Icons.directions_bike_outlined,
    ),
    CategoryIconSpec.material(
      'icon:motorcycle',
      'Motorcycle Scooter',
      Icons.two_wheeler_outlined,
    ),
    CategoryIconSpec.material(
      'icon:flight',
      'Flight Travel Plane',
      Icons.flight_outlined,
    ),
    CategoryIconSpec.material(
      'icon:luggage',
      'Luggage Suitcase',
      Icons.luggage_outlined,
    ),
    CategoryIconSpec.material(
      'icon:book',
      'Book Manual',
      Icons.menu_book_outlined,
    ),
    CategoryIconSpec.material(
      'icon:art',
      'Art Brush Paint',
      Icons.brush_outlined,
    ),
    CategoryIconSpec.material(
      'icon:music',
      'Music Instrument',
      Icons.music_note_outlined,
    ),
    CategoryIconSpec.material('icon:toys', 'Toys Kids', Icons.toys_outlined),
    CategoryIconSpec.material(
      'icon:medical',
      'Medical Health',
      Icons.medical_services_outlined,
    ),
    CategoryIconSpec.material(
      'icon:shopping',
      'Shopping Bag',
      Icons.shopping_bag_outlined,
    ),
    CategoryIconSpec.material(
      'icon:card',
      'Credit Card Payment',
      Icons.credit_card_outlined,
    ),
    CategoryIconSpec.material(
      'icon:receipt',
      'Receipt Invoice',
      Icons.receipt_long_outlined,
    ),
    CategoryIconSpec.material(
      'icon:savings',
      'Savings Value',
      Icons.savings_outlined,
    ),
    CategoryIconSpec.material('icon:key', 'Key Access', Icons.key_outlined),
    CategoryIconSpec.material('icon:lock', 'Lock Security', Icons.lock_outline),
    CategoryIconSpec.material(
      'icon:shield',
      'Shield Warranty Protection',
      Icons.shield_outlined,
    ),
    CategoryIconSpec.material('icon:bed', 'Bed Bedroom', Icons.bed_outlined),
    CategoryIconSpec.material(
      'icon:sofa',
      'Sofa Couch Lounge',
      Icons.weekend_outlined,
    ),
    CategoryIconSpec.material('icon:ac', 'Air Cooling AC', Icons.ac_unit),
    CategoryIconSpec.material(
      'icon:fireplace',
      'Fireplace Heating',
      Icons.fireplace_outlined,
    ),
    CategoryIconSpec.material(
      'icon:water',
      'Water Plumbing',
      Icons.water_drop_outlined,
    ),
    CategoryIconSpec.material(
      'icon:restaurant',
      'Restaurant Dining Food',
      Icons.restaurant_outlined,
    ),
    CategoryIconSpec.material(
      'icon:coffee',
      'Coffee Drink',
      Icons.coffee_outlined,
    ),
    CategoryIconSpec.material('icon:cake', 'Cake Dessert', Icons.cake_outlined),
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
    CategoryIconSpec.emoji('emoji:1f4f7', 'Camera', '\u{1F4F7}'),
    CategoryIconSpec.emoji('emoji:1f3a7', 'Headphones', '\u{1F3A7}'),
    CategoryIconSpec.emoji('emoji:1f4fa', 'TV', '\u{1F4FA}'),
    CategoryIconSpec.emoji('emoji:1f3ae', 'Game', '\u{1F3AE}'),
    CategoryIconSpec.emoji('emoji:1f50b', 'Battery', '\u{1F50B}'),
    CategoryIconSpec.emoji('emoji:1f4a1', 'Idea Bulb', '\u{1F4A1}'),
    CategoryIconSpec.emoji('emoji:1f415', 'Dog Pet', '\u{1F415}'),
    CategoryIconSpec.emoji('emoji:1f6b2', 'Bike', '\u{1F6B2}'),
    CategoryIconSpec.emoji('emoji:1f3cd', 'Motorcycle', '\u{1F3CD}\u{FE0F}'),
    CategoryIconSpec.emoji('emoji:2708', 'Plane Travel', '\u{2708}\u{FE0F}'),
    CategoryIconSpec.emoji('emoji:1f9f3', 'Luggage', '\u{1F9F3}'),
    CategoryIconSpec.emoji('emoji:1f3b5', 'Music', '\u{1F3B5}'),
    CategoryIconSpec.emoji('emoji:1f9f8', 'Toy', '\u{1F9F8}'),
    CategoryIconSpec.emoji('emoji:1f48a', 'Medicine', '\u{1F48A}'),
    CategoryIconSpec.emoji('emoji:1f4b3', 'Card', '\u{1F4B3}'),
    CategoryIconSpec.emoji('emoji:1f9fe', 'Receipt', '\u{1F9FE}'),
    CategoryIconSpec.emoji('emoji:1f511', 'Key', '\u{1F511}'),
    CategoryIconSpec.emoji('emoji:1f512', 'Lock', '\u{1F512}'),
    CategoryIconSpec.emoji('emoji:1f6e1', 'Shield', '\u{1F6E1}\u{FE0F}'),
    CategoryIconSpec.emoji('emoji:1f6cf', 'Bed', '\u{1F6CF}\u{FE0F}'),
    CategoryIconSpec.emoji('emoji:2744', 'Cooling', '\u{2744}\u{FE0F}'),
    CategoryIconSpec.emoji('emoji:1f525', 'Fire Heat', '\u{1F525}'),
    CategoryIconSpec.emoji('emoji:1f4a7', 'Water', '\u{1F4A7}'),
    CategoryIconSpec.emoji('emoji:1f337', 'Flower Plant', '\u{1F337}'),
    CategoryIconSpec.emoji('emoji:1f377', 'Wine Drink', '\u{1F377}'),
    CategoryIconSpec.emoji('emoji:2615', 'Coffee', '\u{2615}'),
    CategoryIconSpec.emoji('emoji:1f382', 'Cake', '\u{1F382}'),
    CategoryIconSpec.emoji('emoji:1f5bc', 'Picture Frame', '\u{1F5BC}\u{FE0F}'),
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
