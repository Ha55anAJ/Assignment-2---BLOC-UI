import '../repositories/item_repository.dart';

/// Fills an empty board with the sample items from the assignment brief.
class SeedItems {
  /// Creates the use case with the [repository] it writes to.
  const SeedItems(this.repository);

  /// Where the sample items are saved.
  final ItemRepository repository;

  /// Runs the use case. Returns `true` if the sample items were written.
  Future<bool> call() => repository.seedItems();
}
