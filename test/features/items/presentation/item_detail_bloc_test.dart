import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found/features/items/domain/entities/item.dart';
import 'package:lost_found/features/items/domain/failures/failure.dart';
import 'package:lost_found/features/items/domain/usecases/claim_item.dart';
import 'package:lost_found/features/items/domain/usecases/delete_item.dart';
import 'package:lost_found/features/items/domain/usecases/watch_item.dart';
import 'package:lost_found/features/items/presentation/bloc/item_detail/item_detail_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_items.dart';

class MockWatchItem extends Mock implements WatchItem {}

class MockClaimItem extends Mock implements ClaimItem {}

class MockDeleteItem extends Mock implements DeleteItem {}

void main() {
  late MockWatchItem watchItem;
  late MockClaimItem claimItem;
  late MockDeleteItem deleteItem;
  late StreamController<Item?> snapshots;

  setUp(() {
    watchItem = MockWatchItem();
    claimItem = MockClaimItem();
    deleteItem = MockDeleteItem();
    snapshots = StreamController<Item?>();
    when(() => watchItem('bottle')).thenAnswer((_) => snapshots.stream);
  });

  tearDown(() {
    // Not awaited: `close` only completes once a listener receives the done
    // event, and some tests never listen.
    snapshots.close();
  });

  ItemDetailBloc buildBloc({Item? initialItem}) => ItemDetailBloc(
    watchItem: watchItem,
    claimItem: claimItem,
    deleteItem: deleteItem,
    itemId: 'bottle',
    initialItem: initialItem,
  );

  test('shows the item from the list straight away', () {
    final state = buildBloc(initialItem: bottle).state;
    expect(state.status, ItemDetailStatus.success);
    expect(state.item, bottle);
  });

  test('waits for the first snapshot without an initial item', () {
    expect(buildBloc().state.status, ItemDetailStatus.loading);
  });

  group('live updates', () {
    blocTest<ItemDetailBloc, ItemDetailState>(
      'follows status changes made on another device',
      build: () => buildBloc(initialItem: bottle),
      act: (bloc) async {
        bloc.add(const ItemDetailSubscriptionRequested());
        await Future<void>.delayed(Duration.zero);
        snapshots.add(bottle);
        await Future<void>.delayed(Duration.zero);
        snapshots.add(claimed(bottle));
      },
      expect: () => [
        isA<ItemDetailState>().having(
          (s) => s.item?.status,
          'item status',
          ItemStatus.found,
        ),
        isA<ItemDetailState>().having(
          (s) => s.item?.status,
          'item status',
          ItemStatus.claimed,
        ),
      ],
    );

    blocTest<ItemDetailBloc, ItemDetailState>(
      'marks the item as removed but keeps the last copy',
      build: () => buildBloc(initialItem: bottle),
      act: (bloc) async {
        bloc.add(const ItemDetailSubscriptionRequested());
        await Future<void>.delayed(Duration.zero);
        snapshots.add(null);
      },
      expect: () => [
        isA<ItemDetailState>()
            .having((s) => s.status, 'status', ItemDetailStatus.removed)
            .having((s) => s.item, 'item', bottle),
      ],
    );
  });

  group('claim', () {
    blocTest<ItemDetailBloc, ItemDetailState>(
      'goes through in progress to success',
      setUp: () => when(() => claimItem('bottle')).thenAnswer((_) async {}),
      build: () => buildBloc(initialItem: bottle),
      act: (bloc) => bloc.add(const ItemDetailClaimRequested()),
      expect: () => [
        isA<ItemDetailState>().having(
          (s) => s.claimStatus,
          'claimStatus',
          ItemActionStatus.inProgress,
        ),
        isA<ItemDetailState>().having(
          (s) => s.claimStatus,
          'claimStatus',
          ItemActionStatus.success,
        ),
      ],
    );

    blocTest<ItemDetailBloc, ItemDetailState>(
      'sends one request for a double tap',
      setUp: () => when(() => claimItem('bottle')).thenAnswer(
        (_) => Future<void>.delayed(const Duration(milliseconds: 10)),
      ),
      build: () => buildBloc(initialItem: bottle),
      act: (bloc) => bloc
        ..add(const ItemDetailClaimRequested())
        ..add(const ItemDetailClaimRequested()),
      wait: const Duration(milliseconds: 50),
      verify: (_) => verify(() => claimItem('bottle')).called(1),
    );

    blocTest<ItemDetailBloc, ItemDetailState>(
      'reports when someone else claimed it first',
      setUp: () =>
          when(() => claimItem('bottle'))
              .thenThrow(const AlreadyClaimedFailure()),
      build: () => buildBloc(initialItem: bottle),
      act: (bloc) => bloc.add(const ItemDetailClaimRequested()),
      skip: 1,
      expect: () => [
        isA<ItemDetailState>()
            .having(
              (s) => s.claimStatus,
              'claimStatus',
              ItemActionStatus.failure,
            )
            .having(
              (s) => s.actionFailure,
              'actionFailure',
              const AlreadyClaimedFailure(),
            ),
      ],
    );

    blocTest<ItemDetailBloc, ItemDetailState>(
      'does nothing for an item that is already claimed',
      build: () => buildBloc(initialItem: keys),
      act: (bloc) => bloc.add(const ItemDetailClaimRequested()),
      expect: () => <ItemDetailState>[],
      verify: (_) => verifyNever(() => claimItem(any())),
    );
  });

  group('delete', () {
    blocTest<ItemDetailBloc, ItemDetailState>(
      'goes through in progress to success',
      setUp: () => when(() => deleteItem('bottle')).thenAnswer((_) async {}),
      build: () => buildBloc(initialItem: bottle),
      act: (bloc) => bloc.add(const ItemDetailDeleteRequested()),
      expect: () => [
        isA<ItemDetailState>().having(
          (s) => s.deleteStatus,
          'deleteStatus',
          ItemActionStatus.inProgress,
        ),
        isA<ItemDetailState>().having(
          (s) => s.deleteStatus,
          'deleteStatus',
          ItemActionStatus.success,
        ),
      ],
    );
  });
}
