import '../repositories/item_repository.dart';

/// Removes an item from the board, for example one posted by mistake.
class DeleteItem {
  /// Creates the use case with the [repository] it writes to.
  const DeleteItem(this.repository);

  /// Where the item is stored.
  final ItemRepository repository;

  /// Runs the use case for the item with [id].
  Future<void> call(String id) => repository.deleteItem(id);
}
