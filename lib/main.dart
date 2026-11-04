import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'core/theme/app_theme.dart';
import 'features/posts/data/datasources/post_remote_data_source.dart';
import 'features/posts/data/repositories/post_repository_impl.dart';
import 'features/posts/domain/usecases/get_posts.dart';
import 'features/posts/presentation/bloc/post_bloc.dart';
import 'features/posts/presentation/pages/posts_page.dart';

void main() {
  runApp(const PostsApp());
}

/// The root of the app.
///
/// This is also where the layers are wired together: the data source feeds the
/// repository, the repository feeds the use case, and the use case feeds the
/// bloc.
class PostsApp extends StatelessWidget {
  /// Creates the app.
  const PostsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: BlocProvider(
        create: (context) {
          final repository = PostRepositoryImpl(
            remoteDataSource: PostRemoteDataSource(client: http.Client()),
          );
          return PostBloc(getPosts: GetPosts(repository))
            ..add(const FetchPosts());
        },
        child: const PostsPage(),
      ),
    );
  }
}
