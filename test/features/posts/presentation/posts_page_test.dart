import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_app/features/posts/domain/entities/post.dart';
import 'package:posts_app/features/posts/domain/failures/failure.dart';
import 'package:posts_app/features/posts/presentation/bloc/post_bloc.dart';
import 'package:posts_app/features/posts/presentation/pages/posts_page.dart';

class MockPostBloc extends MockBloc<PostEvent, PostState> implements PostBloc {}

void main() {
  late MockPostBloc bloc;
  const posts = [
    Post(id: 1, userId: 1, title: 'first title', body: 'first body'),
    Post(id: 2, userId: 2, title: 'second title', body: 'second body'),
  ];

  setUpAll(() {
    // Fonts cannot be downloaded in tests, so fall back to the default font.
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const FetchPosts());
  });

  setUp(() => bloc = MockPostBloc());

  Future<void> pumpPage(WidgetTester tester, PostState state) async {
    whenListen(bloc, const Stream<PostState>.empty(), initialState: state);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PostBloc>.value(
          value: bloc,
          child: const PostsPage(),
        ),
      ),
    );
  }

  testWidgets('shows the skeleton while loading', (tester) async {
    await pumpPage(tester, const PostLoading());

    expect(find.bySemanticsLabel('Loading posts'), findsOneWidget);
    expect(find.text('first title'), findsNothing);
  });

  testWidgets('shows the posts when loaded', (tester) async {
    await pumpPage(tester, const PostLoaded(posts));

    expect(find.text('First title'), findsOneWidget);
    expect(find.text('Second title'), findsOneWidget);
    expect(find.text('2 posts from 2 writers'), findsOneWidget);
  });

  testWidgets('shows the error and retries when the button is tapped', (
    tester,
  ) async {
    await pumpPage(tester, const PostError(NetworkFailure()));

    expect(find.text(const NetworkFailure().message), findsOneWidget);

    await tester.tap(find.text('Try again'));
    verify(() => bloc.add(const FetchPosts())).called(1);
  });

  testWidgets('opens the detail screen when a post is tapped', (tester) async {
    await pumpPage(tester, const PostLoaded(posts));

    await tester.tap(find.text('First title'));
    await tester.pumpAndSettle();

    expect(find.text('First title'), findsOneWidget);
    expect(find.text('First body'), findsOneWidget);
    expect(find.text('Post 1'), findsOneWidget);
  });
}
