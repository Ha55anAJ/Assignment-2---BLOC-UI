import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/post.dart';
import '../utils/post_text.dart';
import 'author_avatar.dart';

/// A tappable summary of a [Post]: author, title and a short preview.
class PostCard extends StatelessWidget {
  /// Creates a card for [post] that calls [onTap] when pressed.
  const PostCard({super.key, required this.post, required this.onTap});

  /// The post to summarize.
  final Post post;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final author = AuthorColors.of(post.userId);

    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.hairline),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'author-${post.id}',
                child: AuthorAvatar(userId: post.userId),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${post.userId}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: author.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.title.capitalized,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.serif(fontSize: 19, height: 1.22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.body.singleLine.capitalized,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.muted, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
