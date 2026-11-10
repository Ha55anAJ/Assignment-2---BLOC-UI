import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found/features/items/data/datasources/item_remote_data_source.dart';
import 'package:lost_found/features/items/data/models/item_model.dart';
import 'package:lost_found/features/items/data/repositories/item_repository_impl.dart';
import 'package:lost_found/features/items/domain/entities/item.dart';
import 'package:lost_found/features/items/domain/failures/failure.dart';
import 'package:mocktail/mocktail.dart';

class MockItemRemoteDataSource extends Mock implements ItemRemoteDataSource {}

FirebaseException firebaseError(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

void main() {
  late MockItemRemoteDataSource dataSource;
  late ItemRepositoryImpl repository;

  const item = ItemModel(
    id: 'a',
    title: 'Grey Jacket',
    category: 'Clothing',
    location: 'Auditorium',
    status: ItemStatus.found,
    description: 'Size M',
    postedBy: 'Mariam',
  );

  setUp(() {
    dataSource = MockItemRemoteDataSource();
    repository = ItemRepositoryImpl(remoteDataSource: dataSource);
  });

  group('claimItem', () {
    test('completes when this call claims the item', () async {
      when(() => dataSource.claimItem('a'))
          .thenAnswer((_) async => ClaimOutcome.claimed);

      await expectLater(repository.claimItem('a'), completes);
    });

    test('throws AlreadyClaimedFailure when someone else won', () {
      when(() => dataSource.claimItem('a'))
          .thenAnswer((_) async => ClaimOutcome.alreadyClaimed);

      expect(repository.claimItem('a'), throwsA(isA<AlreadyClaimedFailure>()));
    });

    test('throws ItemNotFoundFailure when the item was deleted', () {
      when(() => dataSource.claimItem('a'))
          .thenAnswer((_) async => ClaimOutcome.notFound);

      expect(repository.claimItem('a'), throwsA(isA<ItemNotFoundFailure>()));
    });

    test('throws NetworkFailure when Firestore is unavailable', () {
      when(() => dataSource.claimItem('a'))
          .thenThrow(firebaseError('unavailable'));

      expect(repository.claimItem('a'), throwsA(isA<NetworkFailure>()));
    });
  });

  test('deleteItem maps permission-denied to PermissionFailure', () {
    when(() => dataSource.deleteItem('a'))
        .thenThrow(firebaseError('permission-denied'));

    expect(repository.deleteItem('a'), throwsA(isA<PermissionFailure>()));
  });

  test('watchItems passes items through and maps stream errors', () {
    when(() => dataSource.watchItems()).thenAnswer(
      (_) => Stream.fromIterable([
        [item],
      ]).followedBy(Stream.error(firebaseError('permission-denied'))),
    );

    expect(
      repository.watchItems(),
      emitsInOrder([
        [item],
        emitsError(isA<PermissionFailure>()),
      ]),
    );
  });

  test('anything unexpected becomes an UnknownFailure', () {
    expect(
      ItemRepositoryImpl.mapError(StateError('boom')),
      isA<UnknownFailure>(),
    );
  });
}

extension<T> on Stream<T> {
  /// Emits this stream's events, then [next]'s.
  Stream<T> followedBy(Stream<T> next) async* {
    yield* this;
    yield* next;
  }
}
