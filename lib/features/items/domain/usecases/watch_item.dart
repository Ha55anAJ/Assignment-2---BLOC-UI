import '../entities/item.dart';
import '../repositories/item_repository.dart';

/// Streams a single item in real time, so a detail screen stays up to date
/// when the item changes on another device.
class WatchItem {
  /// Creates the use case with the [repository] it reads from.
  const WatchItem(this.repository);

  /// Where the item comes from.
  final ItemRepository repository;

  /// Runs the use case for the item with [id].
  ///
  /// Emits `null` once the item no longer exists.
  Stream<Item?> call(String id) => repository.watchItem(id);
}
