part of 'post_bloc.dart';

/// The base class for everything that can happen to the [PostBloc].
sealed class PostEvent {
  const PostEvent();
}

/// Asks the bloc to load the posts.
///
/// It is used for the first load, for the retry button and for pull-to-refresh.
final class FetchPosts extends PostEvent {
  /// Creates a [FetchPosts] event.
  const FetchPosts();
}
