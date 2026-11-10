part of 'item_detail_bloc.dart';

/// The base class for everything that can happen to the [ItemDetailBloc].
sealed class ItemDetailEvent extends Equatable {
  const ItemDetailEvent();

  @override
  List<Object> get props => [];
}

/// Asks the bloc to start listening to the item's document.
final class ItemDetailSubscriptionRequested extends ItemDetailEvent {
  /// Creates an [ItemDetailSubscriptionRequested] event.
  const ItemDetailSubscriptionRequested();
}

/// The user tapped "Mark as claimed".
final class ItemDetailClaimRequested extends ItemDetailEvent {
  /// Creates an [ItemDetailClaimRequested] event.
  const ItemDetailClaimRequested();
}

/// The user confirmed that the item should be deleted.
final class ItemDetailDeleteRequested extends ItemDetailEvent {
  /// Creates an [ItemDetailDeleteRequested] event.
  const ItemDetailDeleteRequested();
}
