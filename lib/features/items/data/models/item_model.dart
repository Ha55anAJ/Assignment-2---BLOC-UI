import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/item.dart';

/// An [Item] that knows how to read itself from, and write itself to, a
/// Firestore document.
///
/// Keeping the Firestore mapping here, in the data layer, means the domain
/// entity stays free of serialization details.
///
/// A document in the `items` collection looks like this:
///
/// ```json
/// {
///   "title": "Black Backpack",
///   "category": "Bag",
///   "location": "MCC Cafeteria",
///   "status": "Found",
///   "description": "Plain black backpack ...",
///   "postedBy": "Ayesha Khan",
///   "createdAt": Timestamp,
///   "claimedAt": Timestamp | null
/// }
/// ```
class ItemModel extends Item {
  /// Creates an item model.
  const ItemModel({
    required super.id,
    required super.title,
    required super.category,
    required super.location,
    required super.status,
    required super.description,
    required super.postedBy,
    super.createdAt,
    super.claimedAt,
  });

  /// Creates a model for a new item that has not been written yet.
  ///
  /// The [id] is left empty because Firestore generates one when the document
  /// is added, and [createdAt] is left `null` so that [toFirestore] asks the
  /// server for the time.
  factory ItemModel.fromDraft(ItemDraft draft) {
    return ItemModel(
      id: '',
      title: draft.title.trim(),
      category: draft.category.trim(),
      location: draft.location.trim(),
      status: draft.status,
      description: draft.description.trim(),
      postedBy: draft.postedBy.trim(),
    );
  }

  /// Creates an [ItemModel] from a document of the `items` collection.
  ///
  /// This has the signature that [CollectionReference.withConverter] expects.
  ///
  /// The `title` and `status` fields are required. The other text fields fall
  /// back to sensible defaults, so an item typed by hand into the Firebase
  /// console still shows up in the app.
  ///
  /// Throws a [FormatException] or [TypeError] if the document does not look
  /// like an item.
  factory ItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw FormatException('Item ${snapshot.id} has no data');
    }

    final title = (data['title'] as String).trim();
    if (title.isEmpty) {
      throw FormatException('Item ${snapshot.id} has an empty title');
    }

    return ItemModel(
      id: snapshot.id,
      title: title,
      category: _text(data['category'], fallback: 'Other'),
      location: _text(data['location']),
      status: ItemStatus.fromLabel(data['status'] as String),
      description: _text(data['description']),
      postedBy: _text(data['postedBy']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      claimedAt: (data['claimedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts this item into the map that is stored in Firestore.
  ///
  /// The [id] is not stored inside the document, because it is the document's
  /// own id. A `null` [createdAt] becomes a server timestamp.
  Map<String, Object?> toFirestore() {
    return {
      'title': title,
      'category': category,
      'location': location,
      'status': status.label,
      'description': description,
      'postedBy': postedBy,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'claimedAt': claimedAt == null ? null : Timestamp.fromDate(claimedAt!),
    };
  }

  static String _text(Object? value, {String fallback = ''}) {
    final text = (value as String?)?.trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}
