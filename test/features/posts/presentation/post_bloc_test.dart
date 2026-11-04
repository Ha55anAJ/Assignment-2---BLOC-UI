import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_app/features/posts/domain/entities/post.dart';
import 'package:posts_app/features/posts/domain/failures/failure.dart';
import 'package:posts_app/features/posts/domain/usecases/get_posts.dart';
import 'package:posts_app/features/posts/presentation/bloc/post_bloc.dart';

class MockGetPosts extends Mock implements GetPosts {}

void main() {
  late MockGetPosts getPosts;
  const posts = [Post(id: 1, userId: 1, title: 't', body: 'b')];

  setUp(() => getPosts = MockGetPosts());

  test('starts in PostInitial', () {
    expect(PostBloc(getPosts: getPosts).state, isA<PostInitial>());
  });

  blocTest<PostBloc, PostState>(
    'emits loading then loaded when the fetch succeeds',
    build: () {
      when(() => getPosts()).thenAnswer((_) async => posts);
      return PostBloc(getPosts: getPosts);
    },
    act: (bloc) => bloc.add(const FetchPosts()),
    expect: () => [
      isA<PostLoading>(),
      isA<PostLoaded>().having((s) => s.posts, 'posts', posts),
    ],
  );

  blocTest<PostBloc, PostState>(
    'emits loading then error when the fetch fails',
    build: () {
      when(() => getPosts()).thenThrow(const NetworkFailure());
      return PostBloc(getPosts: getPosts);
    },
    act: (bloc) => bloc.add(const FetchPosts()),
    expect: () => [
      isA<PostLoading>(),
      isA<PostError>().having(
        (s) => s.failure,
        'failure',
        isA<NetworkFailure>(),
      ),
    ],
  );

  blocTest<PostBloc, PostState>(
    'keeps showing the posts while refreshing',
    build: () {
      when(() => getPosts()).thenAnswer((_) async => posts);
      return PostBloc(getPosts: getPosts);
    },
    seed: () => const PostLoaded(posts),
    act: (bloc) => bloc.add(const FetchPosts()),
    expect: () => [isA<PostLoaded>()],
  );
}
