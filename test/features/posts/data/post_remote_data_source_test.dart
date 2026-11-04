import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:posts_app/features/posts/data/datasources/post_remote_data_source.dart';

void main() {
  test('fetchPosts parses a JSON array into models', () async {
    final client = MockClient((request) async {
      expect(
        request.url.toString(),
        'https://jsonplaceholder.typicode.com/posts',
      );
      return http.Response(
        '[{"userId":1,"id":1,"title":"t1","body":"b1"},'
        '{"userId":2,"id":2,"title":"t2","body":"b2"}]',
        200,
      );
    });

    final posts = await PostRemoteDataSource(client: client).fetchPosts();

    expect(posts, hasLength(2));
    expect(posts.last.title, 't2');
  });

  test('fetchPosts throws a ServerException for a non-200 response', () {
    final client = MockClient((request) async => http.Response('', 500));

    expect(
      PostRemoteDataSource(client: client).fetchPosts(),
      throwsA(isA<ServerException>()),
    );
  });
}
