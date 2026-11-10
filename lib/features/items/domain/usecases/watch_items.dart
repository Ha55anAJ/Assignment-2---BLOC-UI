import '../entities/item.dart';
import '../repositories/item_repository.dart';

/// Streams the whole board of items in real time.
///
/// A use case represents one thing the app can do. Presentation code calls it
/// like a function: `watchItems()`.
class WatchItems {
  /// Creates the use case with the [repository] it reads from.
  const WatchItems(this.repository);

  /// Where the items come from.
  final ItemRepository repository;

  /// Runs the use case.
  Stream<List<Item>> call() => repository.watchItems();
}
