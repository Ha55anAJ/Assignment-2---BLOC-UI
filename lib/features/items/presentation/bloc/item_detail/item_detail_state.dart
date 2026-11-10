part of 'item_detail_bloc.dart';

/// Where the detail screen is in following the item.
enum ItemDetailStatus {
  /// Waiting for the first snapshot of the item.
  loading,

  /// The item is on screen and up to date.
  success,

  /// The item's document no longer exists.
  removed,

  /// The stream reported an error.
  failure,
}

/// The progress of a one-off action such as claiming or deleting.
enum ItemActionStatus {
  /// The action has not been started.
  idle,

  /// The request is on its way to Firestore.
  inProgress,

  /// Firestore confirmed the action.
  success,

  /// The action failed. See [ItemDetailState.actionFailure].
  failure,
}

/// Everything the detail screen needs to draw itself.
final class ItemDetailState extends Equatable {
  /// Creates an [ItemDetailState].
  const ItemDetailState({
    required this.itemId,
    this.status = ItemDetailStatus.loading,
    this.item,
    this.failure,
    this.claimStatus = ItemActionStatus.idle,
    this.deleteStatus = ItemActionStatus.idle,
    this.actionFailure,
  });

  /// The id of the item being shown.
  final String itemId;

  /// Where the screen is in following the item.
  final ItemDetailStatus status;

  /// The latest version of the item, or `null` before the first snapshot.
  final Item? item;

  /// Why the stream failed, when [status] is [ItemDetailStatus.failure].
  final Failure? failure;

  /// The progress of "Mark as claimed".
  final ItemActionStatus claimStatus;

  /// The progress of "Delete".
  final ItemActionStatus deleteStatus;

  /// Why the last claim or delete failed.
  final Failure? actionFailure;

  /// Whether a claim or delete is currently running.
  bool get isBusy =>
      claimStatus == ItemActionStatus.inProgress ||
      deleteStatus == ItemActionStatus.inProgress;

  /// Returns a copy of this state with the given fields replaced.
  ///
  /// The nullable fields take a function so that they can be set to `null`.
  ItemDetailState copyWith({
    ItemDetailStatus? status,
    ValueGetter<Item?>? item,
    ValueGetter<Failure?>? failure,
    ItemActionStatus? claimStatus,
    ItemActionStatus? deleteStatus,
    ValueGetter<Failure?>? actionFailure,
  }) {
    return ItemDetailState(
      itemId: itemId,
      status: status ?? this.status,
      item: item != null ? item() : this.item,
      failure: failure != null ? failure() : this.failure,
      claimStatus: claimStatus ?? this.claimStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      actionFailure: actionFailure != null
          ? actionFailure()
          : this.actionFailure,
    );
  }

  @override
  List<Object?> get props => [
    itemId,
    status,
    item,
    failure,
    claimStatus,
    deleteStatus,
    actionFailure,
  ];
}
