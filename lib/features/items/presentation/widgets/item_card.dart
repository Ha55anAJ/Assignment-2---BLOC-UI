import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/item.dart';
import '../utils/item_dates.dart';
import 'category_tile.dart';
import 'status_badge.dart';

/// A tappable summary of an [Item]: what it is, where it is and its status.
class ItemCard extends StatelessWidget {
  /// Creates a card for [item] that calls [onTap] when pressed.
  const ItemCard({super.key, required this.item, required this.onTap});

  /// The item to summarize.
  final Item item;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final postedBy = item.postedBy.isEmpty ? 'Anonymous' : item.postedBy;

    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.hairline),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          // Claimed items fade back a little: they are history now.
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 350),
            opacity: item.isClaimed ? 0.62 : 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'item-${item.id}',
                  child: CategoryTile(category: item.category),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.serif(fontSize: 18, height: 1.22),
                      ),
                      const SizedBox(height: 6),
                      if (item.location.isNotEmpty)
                        _IconLine(
                          icon: Icons.place_outlined,
                          text: item.location,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.ink.withValues(alpha: 0.78),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '$postedBy · ${timeAgo(item.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                StatusBadge(status: item.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text, this.style});

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.muted),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}
