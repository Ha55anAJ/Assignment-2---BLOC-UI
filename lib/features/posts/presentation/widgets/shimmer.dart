import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Sweeps a soft highlight across [child] to show that content is loading.
///
/// Based on the shimmer loading effect from the Flutter cookbook. If the user
/// has turned animations off, the child is shown still.
class Shimmer extends StatefulWidget {
  /// Creates a shimmer around [child].
  const Shimmer({super.key, required this.child});

  /// The placeholder shapes to shimmer over.
  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [AppColors.hairline, Colors.white, AppColors.hairline],
              stops: const [0.35, 0.5, 0.65],
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              transform: _SlidingGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

/// Moves a gradient sideways by a fraction of its width.
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Slide from fully off the left edge to fully off the right edge.
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0.0,
      0.0,
    );
  }
}
