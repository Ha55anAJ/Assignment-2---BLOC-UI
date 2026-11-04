part of 'post_bloc.dart';

/// The base class for every state the [PostBloc] can be in.
sealed class PostState {
  const PostState();
}

/// Nothing has been requested yet.
final class PostInitial extends PostState {
  /// Creates a [PostInitial] state.
  const PostInitial();
}

/// The posts are being fetched.
final class PostLoading extends PostState {
  /// Creates a [PostLoading] state.
  const PostLoading();
}

/// The posts were fetched successfully.
///
/// This state deliberately does not override `==`. Every successful fetch
/// emits a new instance, so a pull-to-refresh always produces a state change
/// that listeners can wait for, even when the server returns the same posts.
final class PostLoaded extends PostState {
  /// Creates a [PostLoaded] state holding [posts].
  const PostLoaded(this.posts);

  /// The posts to show.
  final List<Post> posts;
}

/// Fetching the posts failed.
final class PostError extends PostState {
  /// Creates a [PostError] state describing [failure].
  const PostError(this.failure);

  /// What went wrong.
  final Failure failure;
}
