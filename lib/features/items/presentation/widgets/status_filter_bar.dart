import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/items/items_bloc.dart';

/// A row of chips for picking All, Lost, Found or Claimed.
///
/// Each chip shows how many items it would show, given the current search.
class StatusFilterBar extends StatelessWidget {
  /// Creates the filter bar.
  const StatusFilterBar({
    super.key,
    required this.selected,
    required this.countFor,
    required this.onSelected,
  });

  /// The chip that is currently selected.
  final ItemsFilter selected;

  /// Returns the number to show on a chip.
  final int Function(ItemsFilter filter) countFor;

  /// Called when the user picks a chip.
  final ValueChanged<ItemsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final filter in ItemsFilter.values) ...[
            ChoiceChip(
              label: Text('${filter.label}  ${countFor(filter)}'),
              selected: filter == selected,
              onSelected: (_) => onSelected(filter),
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: filter == selected ? Colors.white : AppColors.ink,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
