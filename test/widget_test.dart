// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
//
// These tests run the whole app against a fake, in-memory Firestore, so they
// cover the screens, the blocs, the repository and the data source together.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lost_found/app.dart';
import 'package:lost_found/features/items/data/datasources/item_remote_data_source.dart';
import 'package:lost_found/features/items/data/repositories/item_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ItemRemoteDataSource dataSource;

  setUpAll(() {
    // Fonts cannot be downloaded in tests, so fall back to the default font.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    dataSource = ItemRemoteDataSource(firestore: firestore);
    await dataSource.seedItems();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    // A tall screen so every seeded card is built without scrolling.
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      LostFoundApp(
        repository: ItemRepositoryImpl(remoteDataSource: dataSource),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder chip(String label) => find.byWidgetPredicate(
    (widget) =>
        widget is ChoiceChip &&
        (widget.label as Text).data!.startsWith('$label '),
  );

  testWidgets('shows the seeded items with their counts', (tester) async {
    await pumpApp(tester);

    expect(find.text('Lost & Found'), findsOneWidget);
    expect(find.text('8 items · 8 waiting for their owners'), findsOneWidget);
    expect(find.text('Black Backpack'), findsOneWidget);
    expect(find.text('Grey Jacket'), findsOneWidget);
    expect(find.text('All  8'), findsOneWidget);
    expect(find.text('Lost  3'), findsOneWidget);
    expect(find.text('Found  5'), findsOneWidget);
    expect(find.text('Claimed  0'), findsOneWidget);
  });

  testWidgets('search and status filter work together', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'AR');
    await tester.pumpAndSettle();

    // "Student ID Card" (Found) and "Laptop Charger" (Lost).
    expect(find.text('All  2'), findsOneWidget);
    expect(find.text('Found  1'), findsOneWidget);
    expect(find.text('Lost  1'), findsOneWidget);
    expect(find.text('Student ID Card — M. Ali'), findsOneWidget);
    expect(find.text('Laptop Charger (Dell)'), findsOneWidget);
    expect(find.text('Black Backpack'), findsNothing);

    await tester.tap(chip('Lost'));
    await tester.pumpAndSettle();

    expect(find.text('Laptop Charger (Dell)'), findsOneWidget);
    expect(find.text('Student ID Card — M. Ali'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No matches'), findsOneWidget);

    await tester.tap(find.text('Clear search and filters'));
    await tester.pumpAndSettle();
    expect(find.text('All  8'), findsOneWidget);
    expect(find.text('Black Backpack'), findsOneWidget);
  });

  testWidgets('a change made elsewhere shows up without a refresh', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.runAsync(
      () =>
          firestore.doc('items/seed-grey-jacket').update({'status': 'Claimed'}),
    );
    await tester.pumpAndSettle();

    expect(find.text('Claimed  1'), findsOneWidget);
    expect(find.text('8 items · 7 waiting for their owners'), findsOneWidget);
  });

  testWidgets('the detail screen claims the item and updates live', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Blue Water Bottle'));
    await tester.pumpAndSettle();

    expect(find.textContaining('dent on the bottom'), findsOneWidget);
    expect(find.text('Found at'), findsOneWidget);
    expect(find.text('Library, 2nd Floor'), findsWidgets);

    await tester.tap(find.text('Mark as claimed'));
    await tester.pumpAndSettle();

    expect(find.text('Returned to its owner'), findsOneWidget);
    expect(find.text('Claimed'), findsWidgets);
    final data = (await tester.runAsync(
      () => firestore.doc('items/seed-blue-water-bottle').get(),
    ))!.data()!;
    expect(data['status'], 'Claimed');
  });

  testWidgets('the detail screen deletes the item', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Bunch of Keys'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete item'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this item?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Deleted “Bunch of Keys”'), findsOneWidget);
    expect(find.text('Bunch of Keys'), findsNothing);
    expect(find.text('All  7'), findsOneWidget);
  });

  testWidgets('the add form validates and then posts the item', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Post an item'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Post item'));
    await tester.pumpAndSettle();
    expect(find.text('Give the item a short title'), findsOneWidget);
    expect(find.text('Pick a category'), findsOneWidget);

    await tester.tap(find.text('I lost something'));
    await tester.pumpAndSettle();
    expect(find.text('Where did you lose it?'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Silver Ring',
    );
    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accessory').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Where did you lose it?'),
      'Sports Complex',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Plain silver band, engraved inside.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Your name'),
      'Hassan',
    );
    await tester.tap(find.text('Post item'));
    await tester.pumpAndSettle();

    expect(find.text('Posted! It’s on the board now.'), findsOneWidget);
    expect(find.text('Silver Ring'), findsOneWidget);
    expect(find.text('Lost  4'), findsOneWidget);
  });
}
