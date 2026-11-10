import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/item.dart';

/// A colored pill that says whether an item is Lost, Found or Claimed.
///
/// When the status changes (for example, someone claims the item on another
/// phone) the color fades and the label cross-fades to the new value.
class StatusBadge extends StatelessWidget {
  /// Creates a badge for [status].
  const StatusBadge({super.key, required this.status, this.large = false});

  /// The status to show.
  final ItemStatus status;

  /// Whether to draw the bigger version used on the detail screen.
  final bool large;

  static const _duration = Duration(milliseconds: 350);

  @override
  Widget build(BuildContext context) {
    final colors = StatusColors.of(status);
    final textStyle =
        (large
                ? Theme.of(context).textTheme.labelLarge
                : Theme.of(context).textTheme.labelMedium)
            ?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            );

    return Semantics(
      label: 'Status: ${status.label}',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: large ? 14 : 10,
          vertical: large ? 7 : 5,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: _duration,
              width: large ? 8 : 6,
              height: large ? 8 : 6,
              decoration: BoxDecoration(
                color: colors.foreground,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: large ? 8 : 6),
            AnimatedSwitcher(
              duration: _duration,
              child: Text(
                status.label,
                key: ValueKey(status),
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
