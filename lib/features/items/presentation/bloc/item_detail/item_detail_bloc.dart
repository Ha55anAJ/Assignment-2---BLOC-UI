import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/item.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/usecases/claim_item.dart';
import '../../../domain/usecases/delete_item.dart';
import '../../../domain/usecases/watch_item.dart';

part 'item_detail_event.dart';
part 'item_detail_state.dart';

/// Follows one item in real time and runs the "Mark as claimed" and "Delete"
/// actions for it.
class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  /// Creates a bloc for the item with [itemId].
  ///
  /// Pass the [initialItem] from the list, if there is one, so the screen can
  /// draw straight away while the live subscription starts.
  ItemDetailBloc({
    required this._watchItem,
    required this._claimItem,
    required this._deleteItem,
    required String itemId,
    Item? initialItem,
  }) : super(
         ItemDetailState(
           itemId: itemId,
           item: initialItem,
           status: initialItem == null
               ? ItemDetailStatus.loading
               : ItemDetailStatus.success,
         ),
       ) {
    on<ItemDetailSubscriptionRequested>(
      _onSubscriptionRequested,
      transformer: restartable(),
    );
    // `droppable` ignores new taps while a claim or delete is still running,
    // so a double tap sends a single request. Concurrent taps on *different*
    // devices are handled by the Firestore transaction in the data layer.
    on<ItemDetailClaimRequested>(_onClaimRequested, transformer: droppable());
    on<ItemDetailDeleteRequested>(_onDeleteRequested, transformer: droppable());
  }

  final WatchItem _watchItem;
  final ClaimItem _claimItem;
  final DeleteItem _deleteItem;

  Future<void> _onSubscriptionRequested(
    ItemDetailSubscriptionRequested event,
    Emitter<ItemDetailState> emit,
  ) async {
    await emit.forEach<Item?>(
      _watchItem(state.itemId),
      onData: (item) {
        if (item == null) {
          // Keep the last known item so the screen does not go blank while it
          // closes after a delete.
          return state.copyWith(status: ItemDetailStatus.removed);
        }
        return state.copyWith(
          status: ItemDetailStatus.success,
          item: () => item,
          failure: () => null,
        );
      },
      onError: (error, _) => state.copyWith(
        status: ItemDetailStatus.failure,
        failure: () => error is Failure ? error : const UnknownFailure(),
      ),
    );
  }

  Future<void> _onClaimRequested(
    ItemDetailClaimRequested event,
    Emitter<ItemDetailState> emit,
  ) async {
    if (state.item?.isClaimed ?? true) return;

    emit(
      state.copyWith(
        claimStatus: ItemActionStatus.inProgress,
        actionFailure: () => null,
      ),
    );
    try {
      await _claimItem(state.itemId);
      emit(state.copyWith(claimStatus: ItemActionStatus.success));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          claimStatus: ItemActionStatus.failure,
          actionFailure: () => failure,
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    ItemDetailDeleteRequested event,
    Emitter<ItemDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        deleteStatus: ItemActionStatus.inProgress,
        actionFailure: () => null,
      ),
    );
    try {
      await _deleteItem(state.itemId);
      emit(state.copyWith(deleteStatus: ItemActionStatus.success));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          deleteStatus: ItemActionStatus.failure,
          actionFailure: () => failure,
        ),
      );
    }
  }
}
