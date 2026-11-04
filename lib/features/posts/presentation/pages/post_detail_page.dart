import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/post.dart';
import '../utils/post_text.dart';
import '../widgets/author_avatar.dart';

/// Shows the full title and body of one [Post].
class PostDetailPage extends StatelessWidget {
  /// Creates the detail screen for [post].
  const PostDetailPage({super.key, required this.post});

  /// The post to show.
  final Post post;

  @override
  Widget build(BuildContext context) {
    final author = AuthorColors.of(post.userId);
    final paragraphs = post.body.split('\n').map((line) => line.capitalized);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
      ),
      body: SelectionArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            24,
            8,
            24,
            MediaQuery.paddingOf(context).bottom + 32,
          ),
          children: [
            Row(
              children: [
                Hero(
                  tag: 'author-${post.id}',
                  child: AuthorAvatar(userId: post.userId, size: 52),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${post.userId}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: author.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Post ${post.id}',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              post.title.capitalized,
              style: AppTheme.serif(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            for (final paragraph in paragraphs) ...[
              Text(
                paragraph,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 17.5,
                  height: 1.65,
                  color: AppColors.ink.withValues(alpha: 0.86),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
