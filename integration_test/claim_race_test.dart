// Runs against the real Firestore project, on a device or simulator:
//
//   flutter test integration_test -d <device id>
//
// fake_cloud_firestore runs transactions one after another, so it cannot show
// what happens when two of them collide. This test does, by firing several
// claims at the same document at once and checking that exactly one wins.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lost_found/features/items/data/datasources/item_remote_data_source.dart';
import 'package:lost_found/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('simultaneous claims on one item: exactly one wins', (
    tester,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final dataSource = ItemRemoteDataSource(firestore: firestore);

    // A throwaway item, removed again at the end of the test.
    final itemRef = firestore.collection('items').doc();
    await itemRef.set({
      'title': 'Integration test item',
      'category': 'Other',
      'location': 'Test suite',
      'status': 'Found',
      'description': 'Created and deleted by claim_race_test.dart.',
      'postedBy': 'Integration test',
      'createdAt': FieldValue.serverTimestamp(),
      'claimedAt': null,
    });
    addTearDown(itemRef.delete);

    final outcomes = await Future.wait([
      for (var i = 0; i < 3; i++) dataSource.claimItem(itemRef.id),
    ]);

    expect(outcomes.where((o) => o == ClaimOutcome.claimed), hasLength(1));
    expect(
      outcomes.where((o) => o == ClaimOutcome.alreadyClaimed),
      hasLength(2),
    );

    final data = (await itemRef.get()).data()!;
    expect(data['status'], 'Claimed');
    expect(data['claimedAt'], isA<Timestamp>());
  });
}
