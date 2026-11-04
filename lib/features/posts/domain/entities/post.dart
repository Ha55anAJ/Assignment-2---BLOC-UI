import 'package:equatable/equatable.dart';

/// A single post written by a user.
///
/// This is the plain business object the rest of the app works with. It knows
/// nothing about JSON, HTTP or widgets.
class Post extends Equatable {
  /// Creates a post.
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  /// The unique identifier of this post.
  final int id;

  /// The identifier of the user who wrote this post.
  final int userId;

  /// The headline of the post.
  final String title;

  /// The full text of the post.
  final String body;

  @override
  List<Object> get props => [id, userId, title, body];
}
