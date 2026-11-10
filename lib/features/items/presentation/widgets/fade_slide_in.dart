import 'package:flutter/material.dart';

/// Fades and slides its [child] up into place the first time it is built.
///
/// Give it a key tied to the content (such as the item id) so a newly added
/// item animates in while existing items stay put.
class FadeSlideIn extends StatelessWidget {
  /// Creates the entrance animation, started after [delay].
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  /// The widget to animate in.
  final Widget child;

  /// How long to wait before starting, used to stagger a list.
  final Duration delay;

  static const _duration = Duration(milliseconds: 420);

  @override
  Widget build(BuildContext context) {
    final total = _duration + delay;
    final start = delay.inMilliseconds / total.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
