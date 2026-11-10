import '../entities/item.dart';

/// The contract for reading and changing Lost & Found items.
///
/// The domain layer only declares *what* is needed. The data layer decides
/// *how* to do it (here, with Cloud Firestore).
abstract class ItemRepository {
  /// Emits every item, newest first, and emits again whenever any item is
  /// added, changed or removed.
  ///
  /// The stream reports problems as `Failure` errors.
  Stream<List<Item>> watchItems();

  /// Emits the item with [id] and emits again whenever it changes.
  ///
  /// Emits `null` if the item does not exist, for example after it is deleted.
  /// The stream reports problems as `Failure` errors.
  Stream<Item?> watchItem(String id);

  /// Posts a new item built from [draft].
  ///
  /// Throws a `Failure` if the item cannot be saved.
  Future<void> addItem(ItemDraft draft);

  /// Marks the item with [id] as claimed.
  ///
  /// This is safe to call from several devices at once: exactly one call wins
  /// and every other call throws an `AlreadyClaimedFailure`. Throws an
  /// `ItemNotFoundFailure` if the item has been deleted.
  Future<void> claimItem(String id);

  /// Deletes the item with [id].
  ///
  /// Throws a `Failure` if the item cannot be deleted.
  Future<void> deleteItem(String id);

  /// Writes the sample items the first time the app runs against an empty
  /// project, and does nothing on every later call.
  ///
  /// Returns `true` if the sample items were written by this call.
  Future<bool> seedItems();
}
