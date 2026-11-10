import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// How a category is drawn: its icon and colors.
class ItemCategory {
  const ItemCategory._(this.name, this.icon, this.colors);

  /// The category name stored in Firestore.
  final String name;

  /// The icon shown in the item's tile.
  final IconData icon;

  /// The tile's colors.
  final TintPair colors;

  /// The categories offered in the "Post an item" form, in display order.
  static const List<ItemCategory> all = [
    ItemCategory._(
      'Bag',
      Icons.backpack_rounded,
      TintPair(Color(0xFFFBE4EA), Color(0xFF9B1D45)),
    ),
    ItemCategory._(
      'Accessory',
      Icons.watch_rounded,
      TintPair(Color(0xFFFDEFD2), Color(0xFF8A5300)),
    ),
    ItemCategory._(
      'ID Card',
      Icons.badge_rounded,
      TintPair(Color(0xFFDEE9FB), Color(0xFF1F4FA3)),
    ),
    ItemCategory._(
      'Electronics',
      Icons.cable_rounded,
      TintPair(Color(0xFFD8EFF8), Color(0xFF0F6483)),
    ),
    ItemCategory._(
      'Keys',
      Icons.key_rounded,
      TintPair(Color(0xFFD9F0EE), Color(0xFF126B66)),
    ),
    ItemCategory._(
      'Book',
      Icons.menu_book_rounded,
      TintPair(Color(0xFFE8E0FA), Color(0xFF5B3BB0)),
    ),
    ItemCategory._(
      'Clothing',
      Icons.checkroom_rounded,
      TintPair(Color(0xFFE3F1DA), Color(0xFF3F6B1E)),
    ),
    ItemCategory._(
      'Wallet',
      Icons.account_balance_wallet_rounded,
      TintPair(Color(0xFFFDE3D6), Color(0xFFA8430F)),
    ),
    other,
  ];

  /// Used for "Other" and for any category typed in by hand that the app does
  /// not know.
  static const ItemCategory other = ItemCategory._(
    'Other',
    Icons.inventory_2_rounded,
    TintPair(Color(0xFFE4E7EC), Color(0xFF3A4556)),
  );

  /// Returns the category called [name], ignoring case, or [other].
  static ItemCategory of(String name) {
    final normalized = name.trim().toLowerCase();
    for (final category in all) {
      if (category.name.toLowerCase() == normalized) return category;
    }
    return other;
  }
}
