import 'package:lost_found/features/items/domain/entities/item.dart';

/// A few items shared by the presentation tests.
final backpack = Item(
  id: 'backpack',
  title: 'Black Backpack',
  category: 'Bag',
  location: 'MCC Cafeteria',
  status: ItemStatus.found,
  description: 'Plain black backpack with a rubber-duck keychain.',
  postedBy: 'Ayesha Khan',
  createdAt: DateTime(2026, 11, 10, 9),
);

final bottle = Item(
  id: 'bottle',
  title: 'Blue Water Bottle',
  category: 'Accessory',
  location: 'Library, 2nd Floor',
  status: ItemStatus.found,
  description: 'Steel bottle with a dented bottom.',
  postedBy: 'Hamza Siddiqui',
  createdAt: DateTime(2026, 11, 10, 8),
);

final charger = Item(
  id: 'charger',
  title: 'Laptop Charger (Dell)',
  category: 'Electronics',
  location: 'Room 301',
  status: ItemStatus.lost,
  description: '65 W charger with green tape on the brick.',
  postedBy: 'Sana Mirza',
  createdAt: DateTime(2026, 11, 10, 7),
);

final keys = Item(
  id: 'keys',
  title: 'Bunch of Keys',
  category: 'Keys',
  location: 'Parking Lot',
  status: ItemStatus.claimed,
  description: 'Three keys and a Suzuki car key.',
  postedBy: 'Fatima Noor',
  createdAt: DateTime(2026, 11, 10, 6),
  claimedAt: DateTime(2026, 11, 10, 10),
);

final allItems = [backpack, bottle, charger, keys];

/// Returns [item] with its status changed to claimed.
Item claimed(Item item) => Item(
  id: item.id,
  title: item.title,
  category: item.category,
  location: item.location,
  status: ItemStatus.claimed,
  description: item.description,
  postedBy: item.postedBy,
  createdAt: item.createdAt,
  claimedAt: DateTime(2026, 11, 10, 12),
);
