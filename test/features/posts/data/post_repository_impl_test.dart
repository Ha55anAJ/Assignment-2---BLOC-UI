import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:posts_app/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:posts_app/features/posts/data/models/post_model.dart';
import 'package:posts_app/features/posts/data/repositories/post_repository_impl.dart';
import 'package:posts_app/features/posts/domain/failures/failure.dart';

class MockRemoteDataSource extends Mock implements PostRemoteDataSource {}

void main() {
  late MockRemoteDataSource dataSource;
  late PostRepositoryImpl repository;

  setUp(() {
    dataSource = MockRemoteDataSource();
    repository = PostRepositoryImpl(remoteDataSource: dataSource);
  });

  test('returns the posts from the data source', () async {
    const posts = [PostModel(id: 1, userId: 1, title: 't', body: 'b')];
    when(() => dataSource.fetchPosts()).thenAnswer((_) async => posts);

    expect(await repository.getPosts(), posts);
  });

  group('converts raw errors into failures:', () {
    final cases = <String, (Object, Matcher)>{
      'SocketException': (
        const SocketException('offline'),
        isA<NetworkFailure>(),
      ),
      'ClientException': (
        http.ClientException('offline'),
        isA<NetworkFailure>(),
      ),
      'TimeoutException': (TimeoutException('slow'), isA<NetworkFailure>()),
      'ServerException': (const ServerException(500), isA<ServerFailure>()),
      'FormatException': (
        const FormatException('bad json'),
        isA<DataFailure>(),
      ),
      'anything else': (StateError('boom'), isA<UnknownFailure>()),
    };

    cases.forEach((name, testCase) {
      test(name, () {
        when(() => dataSource.fetchPosts()).thenThrow(testCase.$1);

        expect(repository.getPosts(), throwsA(testCase.$2));
      });
    });
  });
}
