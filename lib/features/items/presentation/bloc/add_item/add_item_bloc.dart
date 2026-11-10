import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/item.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/usecases/add_item.dart';

part 'add_item_event.dart';
part 'add_item_state.dart';

/// Saves the item from the "Post an item" form.
///
/// The form itself validates its fields; this bloc only tracks whether the
/// write to Firestore is running, finished or failed.
class AddItemBloc extends Bloc<AddItemEvent, AddItemState> {
  /// Creates a bloc that saves items with [addItem].
  AddItemBloc({required this._addItem}) : super(const AddItemState()) {
    // Ignore extra taps on "Post" while the first one is still saving.
    on<AddItemSubmitted>(_onSubmitted, transformer: droppable());
  }

  final AddItem _addItem;

  Future<void> _onSubmitted(
    AddItemSubmitted event,
    Emitter<AddItemState> emit,
  ) async {
    emit(const AddItemState(status: AddItemStatus.submitting));
    try {
      await _addItem(event.draft);
      emit(const AddItemState(status: AddItemStatus.success));
    } on Failure catch (failure) {
      emit(AddItemState(status: AddItemStatus.failure, failure: failure));
    }
  }
}
