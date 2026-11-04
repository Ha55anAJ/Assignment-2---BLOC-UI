import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Fetches the list of posts.
///
/// A use case represents one thing the app can do. Presentation code calls it
/// like a function: `getPosts()`.
class GetPosts {
  /// Creates the use case with the [repository] it reads from.
  const GetPosts(this.repository);

  /// Where the posts come from.
  final PostRepository repository;

  /// Runs the use case.
  Future<List<Post>> call() => repository.getPosts();
}
