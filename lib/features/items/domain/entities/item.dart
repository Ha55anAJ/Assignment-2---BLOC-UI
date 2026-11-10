import 'package:equatable/equatable.dart';

/// Where an item is on the Lost & Found board.
enum ItemStatus {
  /// Someone lost the item and is looking for it.
  lost('Lost'),

  /// Someone found the item and is waiting for its owner to collect it.
  found('Found'),

  /// The item has been returned to its owner.
  claimed('Claimed');

  const ItemStatus(this.label);

  /// The text stored in Firestore and shown on the status badge.
  final String label;

  /// Returns the status whose [label] matches [value], ignoring case.
  ///
  /// Throws a [FormatException] if [value] is not a known status.
  static ItemStatus fromLabel(String value) {
    final normalized = value.trim().toLowerCase();
    for (final status in values) {
      if (status.label.toLowerCase() == normalized) return status;
    }
    throw FormatException('Unknown item status', value);
  }
}

/// A lost or found item posted on the board.
///
/// This is the plain business object the rest of the app works with. It knows
/// nothing about Firestore, JSON or widgets.
class Item extends Equatable {
  /// Creates an item.
  const Item({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.status,
    required this.description,
    required this.postedBy,
    this.createdAt,
    this.claimedAt,
  });

  /// The unique identifier of this item (its Firestore document id).
  final String id;

  /// A short name for the item, such as "Black Backpack".
  final String title;

  /// The kind of item, such as "Bag" or "Electronics".
  final String category;

  /// Where the item was lost or found.
  final String location;

  /// Whether the item is lost, found or already claimed.
  final ItemStatus status;

  /// A few sentences that help the owner recognise the item.
  final String description;

  /// The name of the person who posted the item.
  final String postedBy;

  /// When the item was posted.
  ///
  /// This is `null` for a moment after posting, until Firestore fills in the
  /// server timestamp, and for documents added by hand without the field.
  final DateTime? createdAt;

  /// When the item was marked as claimed, or `null` if it has not been.
  final DateTime? claimedAt;

  /// Whether the item has already been returned to its owner.
  bool get isClaimed => status == ItemStatus.claimed;

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    location,
    status,
    description,
    postedBy,
    createdAt,
    claimedAt,
  ];
}

/// The details of an item that has not been posted yet.
///
/// It has no id or timestamps because Firestore assigns those when the item is
/// written.
class ItemDraft extends Equatable {
  /// Creates a draft for a new item.
  const ItemDraft({
    required this.title,
    required this.category,
    required this.location,
    required this.status,
    required this.description,
    required this.postedBy,
  });

  /// See [Item.title].
  final String title;

  /// See [Item.category].
  final String category;

  /// See [Item.location].
  final String location;

  /// See [Item.status]. A new item is either [ItemStatus.lost] or
  /// [ItemStatus.found].
  final ItemStatus status;

  /// See [Item.description].
  final String description;

  /// See [Item.postedBy].
  final String postedBy;

  @override
  List<Object> get props => [
    title,
    category,
    location,
    status,
    description,
    postedBy,
  ];
}
