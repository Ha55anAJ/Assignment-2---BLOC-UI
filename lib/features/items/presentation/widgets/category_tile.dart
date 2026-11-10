import 'package:flutter/material.dart';

import '../utils/item_category.dart';

/// A rounded, tinted square with the icon of an item's category.
class CategoryTile extends StatelessWidget {
  /// Creates a tile for [category] that is [size] pixels wide and tall.
  const CategoryTile({super.key, required this.category, this.size = 48});

  /// The category name, such as "Bag".
  final String category;

  /// The width and height of the tile.
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = ItemCategory.of(category);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.colors.background,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        style.icon,
        size: size * 0.5,
        color: style.colors.foreground,
        semanticLabel: style.name,
      ),
    );
  }
}
