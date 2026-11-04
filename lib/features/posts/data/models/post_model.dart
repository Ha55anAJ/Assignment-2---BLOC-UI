import '../../domain/entities/post.dart';

/// A [Post] that knows how to build itself from JSON.
///
/// Keeping JSON parsing here, in the data layer, means the domain entity stays
/// free of serialization details.
class PostModel extends Post {
  /// Creates a post model.
  const PostModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
  });

  /// Creates a [PostModel] from one object of the API response.
  ///
  /// Throws a [TypeError] if a field is missing or has the wrong type.
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}
