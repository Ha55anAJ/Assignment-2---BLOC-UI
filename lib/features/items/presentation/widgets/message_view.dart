import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// A centered icon, title and message, with an optional button.
///
/// Used for errors, the empty board and "no matches".
class MessageView extends StatelessWidget {
  /// Creates a message view.
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  /// The icon in the circle at the top.
  final IconData icon;

  /// A short headline.
  final String title;

  /// One or two sentences of explanation.
  final String message;

  /// The text of the button. No button is shown if this is `null`.
  final String? actionLabel;

  /// The icon of the button.
  final IconData? actionIcon;

  /// Called when the button is pressed.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.maroon.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: AppColors.maroon),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.serif(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: AppColors.muted, height: 1.45),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon ?? Icons.arrow_forward_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
