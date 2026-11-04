import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post.dart';
import '../../domain/failures/failure.dart';
import '../../domain/usecases/get_posts.dart';

part 'post_event.dart';
part 'post_state.dart';

/// Turns [PostEvent]s into [PostState]s by running the [GetPosts] use case.
class PostBloc extends Bloc<PostEvent, PostState> {
  /// Creates a bloc that loads posts with [getPosts].
  PostBloc({required this._getPosts}) : super(const PostInitial()) {
    on<FetchPosts>(_onFetchPosts);
  }

  final GetPosts _getPosts;

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    // When posts are already on screen (pull-to-refresh), keep showing them
    // instead of flashing a loading state.
    if (state is! PostLoaded) {
      emit(const PostLoading());
    }

    try {
      final posts = await _getPosts();
      emit(PostLoaded(posts));
    } on Failure catch (failure) {
      emit(PostError(failure));
    }
  }
}
