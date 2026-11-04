import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/failures/failure.dart';

/// Explains why the posts could not be loaded and offers a retry button.
class ErrorView extends StatelessWidget {
  /// Creates an error view for [failure] that calls [onRetry] when the user
  /// taps "Try again".
  const ErrorView({super.key, required this.failure, required this.onRetry});

  /// What went wrong.
  final Failure failure;

  /// Called when the user asks to try again.
  final VoidCallback onRetry;

  IconData get _icon => switch (failure) {
    NetworkFailure() => Icons.wifi_off_rounded,
    ServerFailure() => Icons.cloud_off_rounded,
    DataFailure() || UnknownFailure() => Icons.error_outline_rounded,
  };

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
            child: Icon(_icon, size: 38, color: AppColors.maroon),
          ),
          const SizedBox(height: 24),
          Text(
            'Couldn’t load posts',
            textAlign: TextAlign.center,
            style: AppTheme.serif(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            failure.message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: AppColors.muted, height: 1.45),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
