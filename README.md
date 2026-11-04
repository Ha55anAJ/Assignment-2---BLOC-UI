# Posts

A Flutter app that fetches posts from
[JSONPlaceholder](https://jsonplaceholder.typicode.com/posts) and shows them in
a pull-to-refresh list. Built with Clean Architecture and `flutter_bloc` for
the IBA course *Application Development for Mobile Devices (CSE-450)*,
Assignment 2.

## Structure

```
lib/
  core/theme/                  Colors, fonts and ThemeData
  features/posts/
    domain/                    Pure Dart: no Flutter, http or json
      entities/post.dart
      failures/failure.dart
      repositories/post_repository.dart
      usecases/get_posts.dart
    data/
      models/post_model.dart                    Post + fromJson
      datasources/post_remote_data_source.dart  http calls
      repositories/post_repository_impl.dart    Errors -> Failures
    presentation/
      bloc/                    PostBloc, FetchPosts, PostState
      pages/                   Posts list and post detail
      widgets/                 Card, avatar, skeleton, error view
```

Dependencies point inward: presentation and data depend on domain, and domain
depends on nothing. `main.dart` wires the layers together.

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter analyze
flutter test
```
