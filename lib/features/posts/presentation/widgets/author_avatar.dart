import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// A rounded tile showing an author's number in that author's own color.
class AuthorAvatar extends StatelessWidget {
  /// Creates an avatar for the user with [userId].
  const AuthorAvatar({super.key, required this.userId, this.size = 44});

  /// The user this avatar belongs to.
  final int userId;

  /// The width and height of the tile.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AuthorColors.of(userId);

    // The Material ancestor gives the text a default style while the avatar is
    // flying between screens in a Hero transition.
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(size * 0.32),
        ),
        child: Text(
          '$userId',
          style: AppTheme.serif(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
            height: 1,
            color: colors.foreground,
          ),
        ),
      ),
    );
  }
}
