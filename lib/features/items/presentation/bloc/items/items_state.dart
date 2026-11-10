part of 'items_bloc.dart';

/// Where the list is in loading the items.
enum ItemsStatus {
  /// Nothing has been requested yet.
  initial,

  /// Waiting for the first snapshot from Firestore.
  loading,

  /// At least one snapshot has arrived.
  success,

  /// The stream reported an error.
  failure,
}

/// The status chips above the list.
enum ItemsFilter {
  /// Every item, whatever its status.
  all('All'),

  /// Only items that are still lost.
  lost('Lost'),

  /// Only items that are found and waiting for their owner.
  found('Found'),

  /// Only items that have been returned.
  claimed('Claimed');

  const ItemsFilter(this.label);

  /// The text shown on the chip.
  final String label;

  /// Whether [item] should be shown when this filter is selected.
  bool matches(Item item) {
    return switch (this) {
      ItemsFilter.all => true,
      ItemsFilter.lost => item.status == ItemStatus.lost,
      ItemsFilter.found => item.status == ItemStatus.found,
      ItemsFilter.claimed => item.status == ItemStatus.claimed,
    };
  }
}

/// Everything the list screen needs to draw itself.
final class ItemsState extends Equatable {
  /// Creates an [ItemsState].
  const ItemsState({
    this.status = ItemsStatus.initial,
    this.items = const [],
    this.query = '',
    this.filter = ItemsFilter.all,
    this.failure,
    this.deleteFailure,
  });

  /// Where the list is in loading the items.
  final ItemsStatus status;

  /// Every item from the latest Firestore snapshot, newest first.
  final List<Item> items;

  /// The text in the search bar.
  final String query;

  /// The selected status chip.
  final ItemsFilter filter;

  /// Why the stream failed, when [status] is [ItemsStatus.failure].
  final Failure? failure;

  /// Why the last delete failed. It is only set for a single state so the
  /// screen can show a snackbar.
  final Failure? deleteFailure;

  /// Whether [item]'s title contains the search text, ignoring case.
  bool _matchesQuery(Item item) {
    final query = this.query.trim().toLowerCase();
    return query.isEmpty || item.title.toLowerCase().contains(query);
  }

  /// The items that match both the search text and the selected chip.
  ///
  /// Search and filter are applied together, so searching "bottle" with the
  /// "Found" chip selected shows only found bottles.
  List<Item> get visibleItems {
    return [
      for (final item in items)
        if (filter.matches(item) && _matchesQuery(item)) item,
    ];
  }

  /// How many items would be shown if [filter] were selected, given the
  /// current search text. Used for the numbers on the chips.
  int countFor(ItemsFilter filter) {
    return items
        .where((item) => filter.matches(item) && _matchesQuery(item))
        .length;
  }

  /// Whether a search or a chip other than "All" is narrowing the list.
  bool get isFiltering => query.trim().isNotEmpty || filter != ItemsFilter.all;

  /// Returns a copy of this state with the given fields replaced.
  ///
  /// The nullable fields take a function so that they can be set to `null`.
  ItemsState copyWith({
    ItemsStatus? status,
    List<Item>? items,
    String? query,
    ItemsFilter? filter,
    ValueGetter<Failure?>? failure,
    ValueGetter<Failure?>? deleteFailure,
  }) {
    return ItemsState(
      status: status ?? this.status,
      items: items ?? this.items,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      failure: failure != null ? failure() : this.failure,
      deleteFailure: deleteFailure != null
          ? deleteFailure()
          : this.deleteFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    query,
    filter,
    failure,
    deleteFailure,
  ];
}
