import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/post_bloc.dart';
import '../widgets/error_view.dart';
import '../widgets/post_card.dart';
import '../widgets/post_skeleton.dart';
import 'post_detail_page.dart';

/// The home screen: a pull-to-refresh list of posts.
///
/// It expects a [PostBloc] to be provided above it in the widget tree.
class PostsPage extends StatelessWidget {
  /// Creates the posts screen.
  const PostsPage({super.key});

  /// Asks the bloc for fresh posts and completes once it has an answer, so the
  /// refresh indicator knows when to disappear.
  Future<void> _refresh(BuildContext context) {
    final bloc = context.read<PostBloc>()..add(const FetchPosts());
    return bloc.stream.firstWhere((state) => state is! PostLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.maroon,
        edgeOffset: MediaQuery.paddingOf(context).top,
        onRefresh: () => _refresh(context),
        child: CustomScrollView(
          // Keeps pull-to-refresh working even when the content is short, for
          // example on the error screen.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const _Header(),
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                return switch (state) {
                  PostInitial() || PostLoading() => const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: PostSkeleton()),
                  ),
                  PostLoaded(:final posts) => SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      MediaQuery.paddingOf(context).bottom + 16,
                    ),
                    sliver: SliverList.separated(
                      itemCount: posts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostCard(
                          post: post,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => PostDetailPage(post: post),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  PostError(:final failure) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: ErrorView(
                        failure: failure,
                        onRetry: () =>
                            context.read<PostBloc>().add(const FetchPosts()),
                      ),
                    ),
                  ),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The large title at the top of the list, with a line that reflects the
/// current state.
class _Header extends StatelessWidget {
  const _Header();

  String _subtitle(PostState state) {
    return switch (state) {
      PostInitial() || PostLoading() => 'Fetching the latest posts',
      PostLoaded(:final posts) =>
        '${posts.length} posts from '
            '${posts.map((post) => post.userId).toSet().length} writers',
      PostError() => 'The feed is unavailable right now',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.paddingOf(context).top + 32,
          20,
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Posts',
              style: AppTheme.serif(
                fontSize: 46,
                fontWeight: FontWeight.w700,
                height: 1.05,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                final subtitle = _subtitle(state);
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    subtitle,
                    key: ValueKey(subtitle),
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: AppColors.muted),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
