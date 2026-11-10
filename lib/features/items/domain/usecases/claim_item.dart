import '../repositories/item_repository.dart';

/// Marks an item as returned to its owner.
///
/// The repository makes this safe under concurrent taps, see
/// [ItemRepository.claimItem].
class ClaimItem {
  /// Creates the use case with the [repository] it writes to.
  const ClaimItem(this.repository);

  /// Where the item is saved.
  final ItemRepository repository;

  /// Runs the use case for the item with [id].
  Future<void> call(String id) => repository.claimItem(id);
}
