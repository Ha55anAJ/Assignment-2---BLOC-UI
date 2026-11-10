import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Gently pulsing placeholder cards shown until the first snapshot arrives.
class ItemSkeleton extends StatefulWidget {
  /// Creates the loading placeholder.
  const ItemSkeleton({super.key, this.count = 5});

  /// How many placeholder cards to draw.
  final int count;

  @override
  State<ItemSkeleton> createState() => _ItemSkeletonState();
}

class _ItemSkeletonState extends State<ItemSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading items',
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
        child: Column(
          children: [
            for (var i = 0; i < widget.count; i++) ...[
              const _SkeletonCard(),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.hairline),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Block(width: 48, height: 48, radius: 14),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Block(width: 170, height: 16),
                SizedBox(height: 10),
                _Block(width: 120, height: 12),
                SizedBox(height: 8),
                _Block(width: 90, height: 10),
              ],
            ),
          ),
          _Block(width: 56, height: 22, radius: 11),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.width, required this.height, this.radius = 6});

  final double width;
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
