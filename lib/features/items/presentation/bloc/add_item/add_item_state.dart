part of 'add_item_bloc.dart';

/// Where the form is in saving the item.
enum AddItemStatus {
  /// The form has not been submitted yet.
  initial,

  /// The item is being written to Firestore.
  submitting,

  /// The item was saved.
  success,

  /// Saving failed. See [AddItemState.failure].
  failure,
}

/// The state of the "Post an item" form.
final class AddItemState extends Equatable {
  /// Creates an [AddItemState].
  const AddItemState({this.status = AddItemStatus.initial, this.failure});

  /// Where the form is in saving the item.
  final AddItemStatus status;

  /// Why saving failed, when [status] is [AddItemStatus.failure].
  final Failure? failure;

  @override
  List<Object?> get props => [status, failure];
}
