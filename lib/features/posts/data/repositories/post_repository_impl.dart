import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../domain/entities/post.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';

/// Gets posts from the network and reports problems as [Failure]s.
class PostRepositoryImpl implements PostRepository {
  /// Creates a repository that reads from [remoteDataSource].
  const PostRepositoryImpl({required this.remoteDataSource});

  /// The source of the posts.
  final PostRemoteDataSource remoteDataSource;

  @override
  Future<List<Post>> getPosts() async {
    try {
      return await remoteDataSource.fetchPosts();
    } on ServerException {
      throw const ServerFailure();
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    } on FormatException {
      throw const DataFailure();
    } on TypeError {
      throw const DataFailure();
    } catch (_) {
      throw const UnknownFailure();
    }
  }
}
