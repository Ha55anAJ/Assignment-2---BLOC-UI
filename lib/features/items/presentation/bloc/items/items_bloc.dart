import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/item.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/usecases/delete_item.dart';
import '../../../domain/usecases/watch_items.dart';

part 'items_event.dart';
part 'items_state.dart';

/// Keeps the list screen in sync with Firestore and applies the search and
/// status filter on top of it.
class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  /// Creates a bloc that streams items with [watchItems] and removes them with
  /// [deleteItem].
  ItemsBloc({required this._watchItems, required this._deleteItem})
    : super(const ItemsState()) {
    // `restartable` cancels the previous subscription when the user taps
    // "Try again", so there is never more than one listener on the collection.
    on<ItemsSubscriptionRequested>(
      _onSubscriptionRequested,
      transformer: restartable(),
    );
    on<ItemsSearchChanged>(_onSearchChanged);
    on<ItemsFilterChanged>(_onFilterChanged);
    on<ItemsItemDeleted>(_onItemDeleted);
  }

  final WatchItems _watchItems;
  final DeleteItem _deleteItem;

  Future<void> _onSubscriptionRequested(
    ItemsSubscriptionRequested event,
    Emitter<ItemsState> emit,
  ) async {
    emit(state.copyWith(status: ItemsStatus.loading));

    // `emit.forEach` listens to the stream for as long as the bloc is open and
    // emits a new state for every snapshot Firestore sends, so the list
    // updates live without a manual refresh.
    await emit.forEach<List<Item>>(
      _watchItems(),
      onData: (items) => state.copyWith(
        status: ItemsStatus.success,
        items: items,
        failure: () => null,
      ),
      onError: (error, _) => state.copyWith(
        status: ItemsStatus.failure,
        failure: () => error is Failure ? error : const UnknownFailure(),
      ),
    );
  }

  void _onSearchChanged(ItemsSearchChanged event, Emitter<ItemsState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onFilterChanged(ItemsFilterChanged event, Emitter<ItemsState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onItemDeleted(
    ItemsItemDeleted event,
    Emitter<ItemsState> emit,
  ) async {
    // Drop the item straight away so a swiped card does not reappear while
    // Firestore confirms the delete. If the delete fails, Firestore sends a
    // snapshot that still contains the item and the card comes back.
    emit(
      state.copyWith(
        items: [
          for (final item in state.items)
            if (item.id != event.item.id) item,
        ],
      ),
    );

    try {
      await _deleteItem(event.item.id);
    } on Failure catch (failure) {
      // Emit the failure once for the snackbar, then clear it, so the same
      // failure happening again still produces a new state.
      emit(state.copyWith(deleteFailure: () => failure));
      emit(state.copyWith(deleteFailure: () => null));
    }
  }
}
