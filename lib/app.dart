import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/items/domain/repositories/item_repository.dart';
import 'features/items/domain/usecases/delete_item.dart';
import 'features/items/domain/usecases/watch_items.dart';
import 'features/items/presentation/bloc/items/items_bloc.dart';
import 'features/items/presentation/pages/items_page.dart';

/// The root of the app.
///
/// It provides the [ItemRepository] to every screen and starts the live list.
/// `main.dart` creates the Firestore-backed repository; tests pass one backed
/// by a fake Firestore instead.
class LostFoundApp extends StatelessWidget {
  /// Creates the app around [repository].
  const LostFoundApp({super.key, required this.repository});

  /// Where every screen reads and writes items.
  final ItemRepository repository;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ItemRepository>.value(
      value: repository,
      child: MaterialApp(
        title: 'Lost & Found',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: BlocProvider(
          create: (context) => ItemsBloc(
            watchItems: WatchItems(repository),
            deleteItem: DeleteItem(repository),
          )..add(const ItemsSubscriptionRequested()),
          child: const ItemsPage(),
        ),
      ),
    );
  }
}
