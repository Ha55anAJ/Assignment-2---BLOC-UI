import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post_model.dart';

/// Thrown when the server replies with a status code other than 200.
class ServerException implements Exception {
  /// Creates an exception for the given HTTP [statusCode].
  const ServerException(this.statusCode);

  /// The HTTP status code that was returned.
  final int statusCode;

  @override
  String toString() => 'ServerException: status code $statusCode';
}

/// Talks to the posts API.
class PostRemoteDataSource {
  /// Creates a data source that sends requests with [client].
  PostRemoteDataSource({required this.client});

  /// The HTTP client used for every request.
  final http.Client client;

  static final Uri _postsUri = Uri.parse(
    'https://jsonplaceholder.typicode.com/posts',
  );

  static const Duration _timeout = Duration(seconds: 10);

  /// Fetches all posts from the API and parses them into models.
  ///
  /// Throws a [ServerException] if the response is not a 200, and lets
  /// network, timeout and parsing errors pass through to the caller.
  Future<List<PostModel>> fetchPosts() async {
    final response = await client.get(_postsUri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw ServerException(response.statusCode);
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
