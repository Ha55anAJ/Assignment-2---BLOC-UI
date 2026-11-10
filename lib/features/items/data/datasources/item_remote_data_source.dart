import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/item.dart';
import '../models/item_model.dart';
import 'seed_items.dart';

/// What happened when the app tried to claim an item.
enum ClaimOutcome {
  /// This call changed the item's status to Claimed.
  claimed,

  /// The item was already claimed, so nothing was written.
  alreadyClaimed,

  /// The item does not exist (it was deleted).
  notFound,
}

/// Talks to Cloud Firestore.
///
/// This is the only class in the app that uses the `cloud_firestore` package
/// directly. Any [FirebaseException] it throws is turned into a `Failure` by
/// the repository.
class ItemRemoteDataSource {
  /// Creates a data source that reads from and writes to [firestore].
  ItemRemoteDataSource({required this.firestore});

  /// The Firestore instance to use. Tests pass a fake one.
  final FirebaseFirestore firestore;

  /// The name of the collection that holds the items.
  static const String itemsCollection = 'items';

  /// The document that records that the sample items were written.
  static const String seedMarkerPath = 'meta/seed';

  /// The raw `items` collection, used for reads and for writes that only touch
  /// some fields.
  CollectionReference<Map<String, dynamic>> get _rawItems =>
      firestore.collection(itemsCollection);

  /// The `items` collection, typed with [ItemModel].
  ///
  /// `withConverter` lets writes take an [ItemModel] instead of a
  /// `Map<String, dynamic>`.
  CollectionReference<ItemModel> get _items => _rawItems.withConverter(
    fromFirestore: ItemModel.fromFirestore,
    toFirestore: (item, _) => item.toFirestore(),
  );

  /// Listens to the whole `items` collection.
  ///
  /// `snapshots()` emits the current documents straight away and then again
  /// every time a document is added, changed or removed, whether the change
  /// came from this device, another device or the Firebase console.
  ///
  /// The query deliberately has no `orderBy`: Firestore leaves out documents
  /// that are missing the ordered field, and an item typed into the console
  /// may not have a `createdAt`. The items are sorted here instead.
  ///
  /// Documents are converted one at a time (rather than through
  /// `withConverter`) so that one malformed document is skipped instead of
  /// breaking the whole list.
  Stream<List<ItemModel>> watchItems() {
    return _rawItems.snapshots().map((snapshot) {
      final items = <ItemModel>[];
      for (final doc in snapshot.docs) {
        try {
          items.add(ItemModel.fromFirestore(doc, null));
        } on Object catch (error) {
          log('Skipping item ${doc.id}: $error', name: 'ItemRemoteDataSource');
        }
      }
      return items..sort(_newestFirst);
    });
  }

  /// Listens to the document of the item with [id].
  ///
  /// Emits `null` when the document does not exist.
  Stream<ItemModel?> watchItem(String id) {
    return _rawItems
        .doc(id)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.exists ? ItemModel.fromFirestore(snapshot, null) : null,
        );
  }

  /// Adds a new document built from [draft] and lets Firestore pick its id.
  Future<void> addItem(ItemDraft draft) async {
    await _items.add(ItemModel.fromDraft(draft));
  }

  /// Marks the item with [id] as claimed inside a transaction.
  ///
  /// A transaction reads the document and writes it back as one atomic step.
  /// If another device changes the document between the read and the write,
  /// the losing attempt is never applied: Firestore either re-runs the handler
  /// with the fresh data (which then sees the item is already claimed and
  /// writes nothing), or, because `firestore.rules` only allows claiming an
  /// item that is still Lost or Found, rejects the commit with
  /// `permission-denied`. Either way exactly one claim wins and `claimedAt` is
  /// set once.
  Future<ClaimOutcome> claimItem(String id) async {
    try {
      return await _claimInTransaction(id);
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') rethrow;

      // Tell "someone else claimed it a moment ago" apart from a real
      // permission problem by reading the item again from the server.
      final snapshot = await _rawItems
          .doc(id)
          .get(const GetOptions(source: Source.server));
      if (!snapshot.exists) return ClaimOutcome.notFound;
      final status = ItemStatus.fromLabel(snapshot.get('status') as String);
      if (status == ItemStatus.claimed) return ClaimOutcome.alreadyClaimed;
      rethrow;
    }
  }

  Future<ClaimOutcome> _claimInTransaction(String id) {
    // Create a reference to the document the transaction will use
    final itemRef = _rawItems.doc(id);

    return firestore.runTransaction((transaction) async {
      // Get the document
      final snapshot = await transaction.get(itemRef);

      if (!snapshot.exists) {
        return ClaimOutcome.notFound;
      }

      final status = ItemStatus.fromLabel(snapshot.get('status') as String);
      if (status == ItemStatus.claimed) {
        return ClaimOutcome.alreadyClaimed;
      }

      // Perform an update on the document
      transaction.update(itemRef, {
        'status': ItemStatus.claimed.label,
        'claimedAt': FieldValue.serverTimestamp(),
      });

      return ClaimOutcome.claimed;
    });
  }

  /// Deletes the document of the item with [id].
  Future<void> deleteItem(String id) => _rawItems.doc(id).delete();

  /// Writes the sample items once per Firebase project.
  ///
  /// A marker document at [seedMarkerPath] records that seeding happened, so
  /// deleting every item later does not bring the samples back. If the
  /// collection already has items (for example, added by hand in the console),
  /// only the marker is written.
  ///
  /// The write runs in a transaction, so two devices opening the app for the
  /// first time at once still seed the collection only once.
  Future<bool> seedItems({DateTime? now}) async {
    final markerRef = firestore.doc(seedMarkerPath);

    final marker = await markerRef.get();
    if (marker.exists) return false;

    final existing = await _rawItems.limit(1).get();
    final seeds = existing.docs.isEmpty
        ? buildSeedItems(now ?? DateTime.now())
        : const <ItemModel>[];

    return firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(markerRef);
      if (snapshot.exists) return false;

      for (final item in seeds) {
        transaction.set(_items.doc(item.id), item);
      }
      transaction.set(markerRef, {
        'seededAt': FieldValue.serverTimestamp(),
        'count': seeds.length,
      });
      return seeds.isNotEmpty;
    });
  }

  /// Sorts items newest first. Items without a `createdAt` yet were most likely
  /// just posted, so they go to the top.
  static int _newestFirst(Item a, Item b) {
    final aTime = a.createdAt;
    final bTime = b.createdAt;
    if (aTime == null && bTime == null) return a.title.compareTo(b.title);
    if (aTime == null) return -1;
    if (bTime == null) return 1;
    return bTime.compareTo(aTime);
  }
}
