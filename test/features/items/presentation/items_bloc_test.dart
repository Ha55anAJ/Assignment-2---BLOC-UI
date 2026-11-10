import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found/features/items/domain/entities/item.dart';
import 'package:lost_found/features/items/domain/failures/failure.dart';
import 'package:lost_found/features/items/domain/usecases/delete_item.dart';
import 'package:lost_found/features/items/domain/usecases/watch_items.dart';
import 'package:lost_found/features/items/presentation/bloc/items/items_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_items.dart';

class MockWatchItems extends Mock implements WatchItems {}

class MockDeleteItem extends Mock implements DeleteItem {}

void main() {
  late MockWatchItems watchItems;
  late MockDeleteItem deleteItem;
  late StreamController<List<Item>> snapshots;

  setUp(() {
    watchItems = MockWatchItems();
    deleteItem = MockDeleteItem();
    snapshots = StreamController<List<Item>>();
    when(() => watchItems()).thenAnswer((_) => snapshots.stream);
  });

  tearDown(() {
    // Not awaited: `close` only completes once a listener receives the done
    // event, and some tests never listen.
    snapshots.close();
  });

  ItemsBloc buildBloc() =>
      ItemsBloc(watchItems: watchItems, deleteItem: deleteItem);

  test('starts empty with the All filter', () {
    final state = buildBloc().state;
    expect(state.status, ItemsStatus.initial);
    expect(state.filter, ItemsFilter.all);
    expect(state.visibleItems, isEmpty);
  });

  group('subscription', () {
    blocTest<ItemsBloc, ItemsState>(
      'emits loading, then every snapshot as it arrives',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const ItemsSubscriptionRequested());
        await Future<void>.delayed(Duration.zero);
        snapshots.add([backpack]);
        await Future<void>.delayed(Duration.zero);
        snapshots.add([backpack, bottle]);
      },
      expect: () => [
        const ItemsState(status: ItemsStatus.loading),
        ItemsState(status: ItemsStatus.success, items: [backpack]),
        ItemsState(status: ItemsStatus.success, items: [backpack, bottle]),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'emits failure when the stream reports an error',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const ItemsSubscriptionRequested());
        await Future<void>.delayed(Duration.zero);
        snapshots.addError(const NetworkFailure());
      },
      expect: () => [
        const ItemsState(status: ItemsStatus.loading),
        const ItemsState(
          status: ItemsStatus.failure,
          failure: NetworkFailure(),
        ),
      ],
    );
  });

  group('search and filter', () {
    ItemsState stateWith({String query = '', ItemsFilter? filter}) {
      return ItemsState(
        status: ItemsStatus.success,
        items: allItems,
        query: query,
        filter: filter ?? ItemsFilter.all,
      );
    }

    test('All with no search shows every item', () {
      expect(stateWith().visibleItems, allItems);
    });

    test('search matches the title, ignoring case and spaces', () {
      expect(stateWith(query: '  BACK ').visibleItems, [backpack]);
    });

    test('the status filter keeps only matching items', () {
      expect(stateWith(filter: ItemsFilter.found).visibleItems, [
        backpack,
        bottle,
      ]);
      expect(stateWith(filter: ItemsFilter.lost).visibleItems, [charger]);
      expect(stateWith(filter: ItemsFilter.claimed).visibleItems, [keys]);
    });

    test('search and filter are applied together', () {
      expect(
        stateWith(query: 'bottle', filter: ItemsFilter.found).visibleItems,
        [bottle],
      );
      expect(
        stateWith(query: 'bottle', filter: ItemsFilter.lost).visibleItems,
        isEmpty,
      );
    });

    test('chip counts follow the search text', () {
      final state = stateWith(query: 'b');
      // "Black Backpack", "Blue Water Bottle", "Bunch of Keys"
      expect(state.countFor(ItemsFilter.all), 3);
      expect(state.countFor(ItemsFilter.found), 2);
      expect(state.countFor(ItemsFilter.lost), 0);
      expect(state.countFor(ItemsFilter.claimed), 1);
    });

    blocTest<ItemsBloc, ItemsState>(
      'stores the search text and the selected filter',
      build: buildBloc,
      seed: stateWith,
      act: (bloc) => bloc
        ..add(const ItemsSearchChanged('key'))
        ..add(const ItemsFilterChanged(ItemsFilter.claimed)),
      expect: () => [
        stateWith(query: 'key'),
        stateWith(query: 'key', filter: ItemsFilter.claimed),
      ],
      verify: (bloc) => expect(bloc.state.visibleItems, [keys]),
    );
  });

  group('delete', () {
    blocTest<ItemsBloc, ItemsState>(
      'removes the item right away and deletes it in Firestore',
      setUp: () => when(() => deleteItem('bottle')).thenAnswer((_) async {}),
      build: buildBloc,
      seed: () => ItemsState(status: ItemsStatus.success, items: allItems),
      act: (bloc) => bloc.add(ItemsItemDeleted(bottle)),
      expect: () => [
        ItemsState(
          status: ItemsStatus.success,
          items: [backpack, charger, keys],
        ),
      ],
      verify: (_) => verify(() => deleteItem('bottle')).called(1),
    );

    blocTest<ItemsBloc, ItemsState>(
      'reports a failed delete once',
      setUp: () =>
          when(() => deleteItem('bottle')).thenThrow(const PermissionFailure()),
      build: buildBloc,
      seed: () => ItemsState(status: ItemsStatus.success, items: allItems),
      act: (bloc) => bloc.add(ItemsItemDeleted(bottle)),
      expect: () => [
        ItemsState(
          status: ItemsStatus.success,
          items: [backpack, charger, keys],
        ),
        ItemsState(
          status: ItemsStatus.success,
          items: [backpack, charger, keys],
          deleteFailure: const PermissionFailure(),
        ),
        ItemsState(
          status: ItemsStatus.success,
          items: [backpack, charger, keys],
        ),
      ],
    );
  });
}
