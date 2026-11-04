import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'shimmer.dart';

/// Placeholder cards shown while the first fetch is in progress.
class PostSkeleton extends StatelessWidget {
  /// Creates the loading placeholder.
  const PostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading posts',
      child: ExcludeSemantics(
        child: Column(children: List.generate(6, (_) => const _SkeletonCard())),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.hairline),
      ),
      // Only the bones are inside the shimmer, so the card itself stays still.
      child: const Shimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Bone(width: 44, height: 44, radius: 14),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(width: 56, height: 12),
                  SizedBox(height: 10),
                  _Bone(height: 18),
                  SizedBox(height: 6),
                  _Bone(width: 180, height: 18),
                  SizedBox(height: 14),
                  _Bone(height: 12),
                  SizedBox(height: 6),
                  _Bone(width: 120, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One grey rounded bar. The shimmer paints its highlight over these.
class _Bone extends StatelessWidget {
  const _Bone({this.width, required this.height, this.radius = 6});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.hairline,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
