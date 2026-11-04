import 'package:flutter_test/flutter_test.dart';
import 'package:posts_app/features/posts/data/models/post_model.dart';
import 'package:posts_app/features/posts/domain/entities/post.dart';

void main() {
  const json = {'userId': 1, 'id': 2, 'title': 'a title', 'body': 'a body'};

  test('fromJson builds a PostModel with every field', () {
    final model = PostModel.fromJson(json);

    expect(model, isA<Post>());
    expect(model.id, 2);
    expect(model.userId, 1);
    expect(model.title, 'a title');
    expect(model.body, 'a body');
  });

  test('fromJson throws a TypeError when a field has the wrong type', () {
    expect(
      () => PostModel.fromJson({...json, 'id': 'not a number'}),
      throwsA(isA<TypeError>()),
    );
  });
}
