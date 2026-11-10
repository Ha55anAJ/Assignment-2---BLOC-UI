import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/failures/failure.dart';
import '../bloc/items/items_bloc.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/item_card.dart';
import '../widgets/item_search_field.dart';
import '../widgets/item_skeleton.dart';
import '../widgets/message_view.dart';
import '../widgets/status_filter_bar.dart';
import 'add_item_page.dart';
import 'item_detail_page.dart';

/// The home screen: every item on the board, live from Firestore, with a
/// search bar and status chips.
///
/// It expects an [ItemsBloc] to be provided above it in the widget tree.
class ItemsPage extends StatelessWidget {
  /// Creates the list screen.
  const ItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemsBloc, ItemsState>(
      listenWhen: (previous, current) => current.deleteFailure != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.deleteFailure!.message)));
      },
      child: Scaffold(
        body: const CustomScrollView(
          slivers: [
            _Header(),
            PinnedHeaderSliver(child: _SearchAndFilters()),
            _ItemsList(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(AddItemPage.route()),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Post an item'),
        ),
      ),
    );
  }
}

/// The large title at the top of the list, with a line that reflects the
/// current state of the board.
class _Header extends StatelessWidget {
  const _Header();

  String _subtitle(ItemsState state) {
    switch (state.status) {
      case ItemsStatus.initial || ItemsStatus.loading:
        return 'Checking the board…';
      case ItemsStatus.failure:
        return 'The board is unavailable right now';
      case ItemsStatus.success:
        final total = state.items.length;
        final waiting = state.items.where((item) => !item.isClaimed).length;
        if (total == 0) return 'Nothing on the board yet';
        return '$total ${total == 1 ? 'item' : 'items'} · '
            '$waiting waiting for ${waiting == 1 ? 'its owner' : 'their owners'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.paddingOf(context).top + 28,
          20,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IBA CAMPUS',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.maroon,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Lost & Found',
              style: AppTheme.serif(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                height: 1.05,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            BlocBuilder<ItemsBloc, ItemsState>(
              buildWhen: (previous, current) =>
                  _subtitle(previous) != _subtitle(current),
              builder: (context, state) {
                final subtitle = _subtitle(state);
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    subtitle,
                    key: ValueKey(subtitle),
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: AppColors.muted),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The search bar and status chips. They stay pinned to the top while the
/// list scrolls underneath.
class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.canvas,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 14),
        child: BlocBuilder<ItemsBloc, ItemsState>(
          builder: (context, state) {
            final bloc = context.read<ItemsBloc>();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ItemSearchField(
                    query: state.query,
                    onChanged: (query) => bloc.add(ItemsSearchChanged(query)),
                  ),
                ),
                const SizedBox(height: 12),
                StatusFilterBar(
                  selected: state.filter,
                  countFor: state.countFor,
                  onSelected: (filter) => bloc.add(ItemsFilterChanged(filter)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The list itself, or a skeleton, an error or an empty state.
class _ItemsList extends StatelessWidget {
  const _ItemsList();

  @override
  Widget build(BuildContext context) {
    // Leave room under the last card for the floating action button.
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 96;

    return BlocBuilder<ItemsBloc, ItemsState>(
      builder: (context, state) {
        final bloc = context.read<ItemsBloc>();

        switch (state.status) {
          case ItemsStatus.initial || ItemsStatus.loading:
            return const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: ItemSkeleton()),
            );

          case ItemsStatus.failure:
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: MessageView(
                  icon: switch (state.failure) {
                    NetworkFailure() => Icons.wifi_off_rounded,
                    PermissionFailure() => Icons.lock_outline_rounded,
                    _ => Icons.error_outline_rounded,
                  },
                  title: 'Couldn’t load the board',
                  message:
                      state.failure?.message ?? const UnknownFailure().message,
                  actionLabel: 'Try again',
                  actionIcon: Icons.refresh_rounded,
                  onAction: () => bloc.add(const ItemsSubscriptionRequested()),
                ),
              ),
            );

          case ItemsStatus.success:
            if (state.items.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: MessageView(
                    icon: Icons.inventory_2_outlined,
                    title: 'Nothing posted yet',
                    message:
                        'Lost something, or found something that isn’t '
                        'yours? Post it so the campus can help.',
                    actionLabel: 'Post an item',
                    actionIcon: Icons.add_rounded,
                    onAction: () =>
                        Navigator.of(context).push(AddItemPage.route()),
                  ),
                ),
              );
            }

            final items = state.visibleItems;
            if (items.isEmpty) {
              final query = state.query.trim();
              final scope = state.filter == ItemsFilter.all
                  ? ''
                  : '${state.filter.label.toLowerCase()} ';
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: MessageView(
                    icon: Icons.search_off_rounded,
                    title: 'No matches',
                    message: query.isEmpty
                        ? 'There are no ${scope}items right now.'
                        : 'No ${scope}items match “$query”.',
                    actionLabel: 'Clear search and filters',
                    actionIcon: Icons.filter_alt_off_rounded,
                    onAction: () => bloc
                      ..add(const ItemsSearchChanged(''))
                      ..add(const ItemsFilterChanged(ItemsFilter.all)),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Dismissible(
                    key: ValueKey('item-${item.id}'),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => confirmDelete(context, item),
                    onDismissed: (_) => bloc.add(ItemsItemDeleted(item)),
                    background: const _DeleteBackground(),
                    child: FadeSlideIn(
                      delay: Duration(milliseconds: 40 * index.clamp(0, 8)),
                      child: ItemCard(
                        item: item,
                        onTap: () =>
                            Navigator.of(context)
                                .push(ItemDetailPage.route(item)),
                      ),
                    ),
                  );
                },
              ),
            );
        }
      },
    );
  }
}

/// What shows behind a card while it is swiped away.
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Delete',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: error, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Icon(Icons.delete_outline_rounded, color: error),
        ],
      ),
    );
  }
}
