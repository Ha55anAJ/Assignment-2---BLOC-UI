import '../entities/post.dart';

/// The contract for getting posts.
///
/// The domain layer only declares *what* is needed. The data layer decides
/// *how* to get it.
abstract class PostRepository {
  /// Returns every available post.
  ///
  /// Throws a `Failure` if the posts cannot be loaded.
  Future<List<Post>> getPosts();
}
