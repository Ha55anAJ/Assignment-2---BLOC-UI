import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_app/features/posts/domain/entities/post.dart';
import 'package:posts_app/features/posts/domain/repositories/post_repository.dart';
import 'package:posts_app/features/posts/domain/usecases/get_posts.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  test('returns whatever the repository returns', () async {
    final repository = MockPostRepository();
    const posts = [Post(id: 1, userId: 1, title: 't', body: 'b')];
    when(() => repository.getPosts()).thenAnswer((_) async => posts);

    expect(await GetPosts(repository)(), posts);
    verify(() => repository.getPosts()).called(1);
  });
}
