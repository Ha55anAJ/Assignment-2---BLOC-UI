import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found/features/items/domain/entities/item.dart';
import 'package:lost_found/features/items/domain/failures/failure.dart';
import 'package:lost_found/features/items/domain/usecases/add_item.dart';
import 'package:lost_found/features/items/presentation/bloc/add_item/add_item_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAddItem extends Mock implements AddItem {}

void main() {
  late MockAddItem addItem;

  const draft = ItemDraft(
    title: 'Grey Jacket',
    category: 'Clothing',
    location: 'Auditorium',
    status: ItemStatus.found,
    description: 'Size M hoodie.',
    postedBy: 'Mariam',
  );

  setUp(() => addItem = MockAddItem());

  blocTest<AddItemBloc, AddItemState>(
    'emits submitting then success when the item is saved',
    setUp: () => when(() => addItem(draft)).thenAnswer((_) async {}),
    build: () => AddItemBloc(addItem: addItem),
    act: (bloc) => bloc.add(const AddItemSubmitted(draft)),
    expect: () => const [
      AddItemState(status: AddItemStatus.submitting),
      AddItemState(status: AddItemStatus.success),
    ],
    verify: (_) => verify(() => addItem(draft)).called(1),
  );

  blocTest<AddItemBloc, AddItemState>(
    'emits submitting then failure when saving fails',
    setUp: () => when(() => addItem(draft)).thenThrow(const NetworkFailure()),
    build: () => AddItemBloc(addItem: addItem),
    act: (bloc) => bloc.add(const AddItemSubmitted(draft)),
    expect: () => const [
      AddItemState(status: AddItemStatus.submitting),
      AddItemState(status: AddItemStatus.failure, failure: NetworkFailure()),
    ],
  );
}
