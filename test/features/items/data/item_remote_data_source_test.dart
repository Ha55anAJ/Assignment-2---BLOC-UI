import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found/features/items/data/datasources/item_remote_data_source.dart';
import 'package:lost_found/features/items/domain/entities/item.dart';

/// A Firestore whose transactions always lose a race: another device claims
/// the item first, so the security rules reject this commit with
/// permission-denied (which is what the real server does).
class LosingRaceFirestore extends FakeFirebaseFirestore {
  /// Whether the other device should actually claim the item before this
  /// commit is rejected.
  bool otherDeviceClaims = true;

  @override
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    if (otherDeviceClaims) {
      await collection('items').doc('a').update({'status': 'Claimed'});
    }
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
    );
  }
}

void main() {
  late FakeFirebaseFirestore firestore;
  late ItemRemoteDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = ItemRemoteDataSource(firestore: firestore);
  });

  Future<void> putItem(
    String id, {
    String title = 'Black Backpack',
    String status = 'Found',
    DateTime? createdAt,
  }) {
    return firestore.collection('items').doc(id).set({
      'title': title,
      'category': 'Bag',
      'location': 'MCC Cafeteria',
      'status': status,
      'description': 'A plain black backpack.',
      'postedBy': 'Ayesha',
      'createdAt': ?(createdAt == null ? null : Timestamp.fromDate(createdAt)),
    });
  }

  group('watchItems', () {
    test('emits the items newest first', () async {
      await putItem('old', title: 'Old', createdAt: DateTime(2026, 1, 1));
      await putItem('new', title: 'New', createdAt: DateTime(2026, 1, 3));
      await putItem('mid', title: 'Mid', createdAt: DateTime(2026, 1, 2));

      final items = await dataSource.watchItems().first;

      expect(items.map((item) => item.id), ['new', 'mid', 'old']);
    });

    test('includes documents without createdAt, at the top', () async {
      await putItem('dated', createdAt: DateTime(2026, 1, 1));
      await putItem('typed-in-console');

      final items = await dataSource.watchItems().first;

      expect(items.map((item) => item.id), ['typed-in-console', 'dated']);
      expect(items.first.createdAt, isNull);
    });

    test('skips documents that are not valid items', () async {
      await putItem('good');
      await firestore.collection('items').doc('bad').set({'title': 42});

      final items = await dataSource.watchItems().first;

      expect(items.map((item) => item.id), ['good']);
    });

    test('emits again when an item changes', () async {
      await putItem('a', status: 'Found');

      final statuses = dataSource
          .watchItems()
          .map((items) => items.single.status)
          .take(2)
          .toList();

      await Future<void>.delayed(Duration.zero);
      await firestore.collection('items').doc('a').update({
        'status': 'Claimed',
      });

      expect(await statuses, [ItemStatus.found, ItemStatus.claimed]);
    });
  });

  group('watchItem', () {
    test('emits the item and then null once it is deleted', () async {
      await putItem('a');

      final events = dataSource.watchItem('a').take(2).toList();
      await Future<void>.delayed(Duration.zero);
      await dataSource.deleteItem('a');

      final result = await events;
      expect(result.first?.title, 'Black Backpack');
      expect(result.last, isNull);
    });
  });

  group('addItem', () {
    test('writes every field and a server timestamp', () async {
      await dataSource.addItem(
        const ItemDraft(
          title: '  Grey Jacket ',
          category: 'Clothing',
          location: 'Auditorium',
          status: ItemStatus.lost,
          description: 'Size M',
          postedBy: 'Mariam',
        ),
      );

      final docs = (await firestore.collection('items').get()).docs;
      expect(docs, hasLength(1));
      final data = docs.single.data();
      expect(data['title'], 'Grey Jacket');
      expect(data['status'], 'Lost');
      expect(data['postedBy'], 'Mariam');
      expect(data['createdAt'], isA<Timestamp>());
      expect(data['claimedAt'], isNull);
    });
  });

  group('claimItem', () {
    test('marks a found item as claimed and records when', () async {
      await putItem('a', status: 'Found');

      final outcome = await dataSource.claimItem('a');

      expect(outcome, ClaimOutcome.claimed);
      final data = (await firestore.doc('items/a').get()).data()!;
      expect(data['status'], 'Claimed');
      expect(data['claimedAt'], isA<Timestamp>());
    });

    test('does not write anything if the item is already claimed', () async {
      await putItem('a', status: 'Found');
      await dataSource.claimItem('a');
      final firstClaim = (await firestore.doc('items/a').get()).get(
        'claimedAt',
      );

      final outcome = await dataSource.claimItem('a');

      expect(outcome, ClaimOutcome.alreadyClaimed);
      final data = (await firestore.doc('items/a').get()).data()!;
      expect(data['claimedAt'], firstClaim);
    });

    test('reports a deleted item as not found', () async {
      expect(await dataSource.claimItem('missing'), ClaimOutcome.notFound);
    });

    test('reports a race lost to another device as already claimed', () async {
      final racing = LosingRaceFirestore();
      await racing.collection('items').doc('a').set({
        'title': 'Black Backpack',
        'status': 'Found',
      });

      final outcome = await ItemRemoteDataSource(firestore: racing)
          .claimItem('a');

      expect(outcome, ClaimOutcome.alreadyClaimed);
    });

    test('rethrows a real permission error', () async {
      final racing = LosingRaceFirestore()..otherDeviceClaims = false;
      await racing.collection('items').doc('a').set({
        'title': 'Black Backpack',
        'status': 'Found',
      });

      expect(
        ItemRemoteDataSource(firestore: racing).claimItem('a'),
        throwsA(
          isA<FirebaseException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    });
  });

  group('deleteItem', () {
    test('removes the document', () async {
      await putItem('a');

      await dataSource.deleteItem('a');

      expect((await firestore.doc('items/a').get()).exists, isFalse);
    });
  });

  group('seedItems', () {
    test('writes the eight sample items once', () async {
      expect(await dataSource.seedItems(), isTrue);
      expect(await dataSource.seedItems(), isFalse);

      final items = await dataSource.watchItems().first;
      expect(items, hasLength(8));
      expect(items.first.title, 'Black Backpack');
      expect(items.last.title, 'Grey Jacket');
      expect(
        items.where((item) => item.status == ItemStatus.lost),
        hasLength(3),
      );
    });

    test('does not bring the samples back after they are deleted', () async {
      await dataSource.seedItems();
      for (final doc in (await firestore.collection('items').get()).docs) {
        await doc.reference.delete();
      }

      expect(await dataSource.seedItems(), isFalse);
      expect((await firestore.collection('items').get()).docs, isEmpty);
    });

    test('leaves a collection that already has items alone', () async {
      await putItem('mine');

      expect(await dataSource.seedItems(), isFalse);

      final items = await dataSource.watchItems().first;
      expect(items.map((item) => item.id), ['mine']);
    });
  });
}
