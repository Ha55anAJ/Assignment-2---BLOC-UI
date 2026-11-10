import '../../domain/entities/item.dart';
import '../models/item_model.dart';

/// The sample items from the assignment brief.
///
/// Each one has a fixed document id, so writing them twice can never create
/// duplicates. [createdAt] is spread over the last day so that the list shows
/// them in the same order as the table in the brief (newest first).
List<ItemModel> buildSeedItems(DateTime now) {
  DateTime hoursAgo(int hours) => now.subtract(Duration(hours: hours));

  return [
    ItemModel(
      id: 'seed-black-backpack',
      title: 'Black Backpack',
      category: 'Bag',
      location: 'MCC Cafeteria',
      status: ItemStatus.found,
      description:
          'Plain black backpack left under a table near the cashier around '
          'lunchtime. It has a padded laptop sleeve and a small rubber-duck '
          'keychain on the zip. Handed over to the cafeteria counter.',
      postedBy: 'Ayesha Khan',
      createdAt: hoursAgo(1),
    ),
    ItemModel(
      id: 'seed-blue-water-bottle',
      title: 'Blue Water Bottle',
      category: 'Accessory',
      location: 'Library, 2nd Floor',
      status: ItemStatus.found,
      description:
          'Steel water bottle, navy blue, with a dent on the bottom and a few '
          'travel stickers on the side. Found on a study desk by the window.',
      postedBy: 'Hamza Siddiqui',
      createdAt: hoursAgo(3),
    ),
    ItemModel(
      id: 'seed-student-id-card',
      title: 'Student ID Card — M. Ali',
      category: 'ID Card',
      location: 'Main Gate',
      status: ItemStatus.found,
      description:
          'IBA student card in a clear holder on a red lanyard. Picked up near '
          'the security desk at the main gate, now kept with the guard on duty.',
      postedBy: 'Bilal Ahmed',
      createdAt: hoursAgo(5),
    ),
    ItemModel(
      id: 'seed-laptop-charger-dell',
      title: 'Laptop Charger (Dell)',
      category: 'Electronics',
      location: 'Room 301',
      status: ItemStatus.lost,
      description:
          '65 W Dell charger with the round barrel pin and a strip of green '
          'tape on the brick. Probably left plugged in under the back row '
          'after the 11:30 class.',
      postedBy: 'Sana Mirza',
      createdAt: hoursAgo(8),
    ),
    ItemModel(
      id: 'seed-umbrella-black',
      title: 'Umbrella (Black)',
      category: 'Accessory',
      location: 'Admin Block',
      status: ItemStatus.lost,
      description:
          'Folding black umbrella with a curved wooden handle, in a grey '
          'sleeve. Left at the Admin Block entrance on a rainy morning.',
      postedBy: 'Usman Tariq',
      createdAt: hoursAgo(11),
    ),
    ItemModel(
      id: 'seed-bunch-of-keys',
      title: 'Bunch of Keys',
      category: 'Keys',
      location: 'Parking Lot',
      status: ItemStatus.found,
      description:
          'Three keys on a steel ring with a Suzuki car key and a tiny torch. '
          'Found on the ground next to the motorbike parking.',
      postedBy: 'Fatima Noor',
      createdAt: hoursAgo(14),
    ),
    ItemModel(
      id: 'seed-calculus-textbook',
      title: 'Calculus Textbook',
      category: 'Book',
      location: 'Student Lounge',
      status: ItemStatus.lost,
      description:
          'Thomas’ Calculus, 14th edition. My name is written inside the front '
          'cover and chapter 5 is full of pencil notes. Last seen on the sofas '
          'in the lounge.',
      postedBy: 'Zain Abbas',
      createdAt: hoursAgo(18),
    ),
    ItemModel(
      id: 'seed-grey-jacket',
      title: 'Grey Jacket',
      category: 'Clothing',
      location: 'Auditorium',
      status: ItemStatus.found,
      description:
          'Grey zip-up hoodie, size M, left on a seat in row F after the '
          'orientation session. Now at the auditorium front desk.',
      postedBy: 'Mariam Raza',
      createdAt: hoursAgo(22),
    ),
  ];
}
