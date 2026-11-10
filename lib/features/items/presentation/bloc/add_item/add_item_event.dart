part of 'add_item_bloc.dart';

/// The base class for everything that can happen to the [AddItemBloc].
sealed class AddItemEvent extends Equatable {
  const AddItemEvent();

  @override
  List<Object> get props => [];
}

/// The user submitted a valid form.
final class AddItemSubmitted extends AddItemEvent {
  /// Creates an [AddItemSubmitted] event for [draft].
  const AddItemSubmitted(this.draft);

  /// The item to post.
  final ItemDraft draft;

  @override
  List<Object> get props => [draft];
}
