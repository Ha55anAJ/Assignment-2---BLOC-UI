import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/item.dart';

/// Asks the user to confirm deleting [item].
///
/// Returns `true` only if they tap "Delete".
Future<bool> confirmDelete(BuildContext context, Item item) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.maroon),
      title: Text('Delete this item?', style: AppTheme.serif(fontSize: 22)),
      content: Text(
        '“${item.title}” will be removed from the board for everyone. '
        'This can’t be undone.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            minimumSize: const Size(64, 44),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
