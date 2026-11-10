part of 'items_bloc.dart';

/// The base class for everything that can happen to the [ItemsBloc].
sealed class ItemsEvent extends Equatable {
  const ItemsEvent();

  @override
  List<Object> get props => [];
}

/// Asks the bloc to start listening to the items in Firestore.
///
/// It is used once when the screen opens and again by the retry button.
final class ItemsSubscriptionRequested extends ItemsEvent {
  /// Creates an [ItemsSubscriptionRequested] event.
  const ItemsSubscriptionRequested();
}

/// The text in the search bar changed.
final class ItemsSearchChanged extends ItemsEvent {
  /// Creates an [ItemsSearchChanged] event for [query].
  const ItemsSearchChanged(this.query);

  /// The new search text.
  final String query;

  @override
  List<Object> get props => [query];
}

/// The user picked a different status chip.
final class ItemsFilterChanged extends ItemsEvent {
  /// Creates an [ItemsFilterChanged] event for [filter].
  const ItemsFilterChanged(this.filter);

  /// The newly selected filter.
  final ItemsFilter filter;

  @override
  List<Object> get props => [filter];
}

/// The user swiped an item away to delete it.
final class ItemsItemDeleted extends ItemsEvent {
  /// Creates an [ItemsItemDeleted] event for [item].
  const ItemsItemDeleted(this.item);

  /// The item to delete.
  final Item item;

  @override
  List<Object> get props => [item];
}
