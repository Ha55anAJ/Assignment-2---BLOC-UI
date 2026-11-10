import '../entities/item.dart';
import '../repositories/item_repository.dart';

/// Posts a new lost or found item.
class AddItem {
  /// Creates the use case with the [repository] it writes to.
  const AddItem(this.repository);

  /// Where the item is saved.
  final ItemRepository repository;

  /// Runs the use case.
  Future<void> call(ItemDraft draft) => repository.addItem(draft);
}
