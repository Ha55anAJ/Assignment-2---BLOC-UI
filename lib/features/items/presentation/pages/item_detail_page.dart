import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/usecases/claim_item.dart';
import '../../domain/usecases/delete_item.dart';
import '../../domain/usecases/watch_item.dart';
import '../bloc/item_detail/item_detail_bloc.dart';
import '../utils/item_category.dart';
import '../utils/item_dates.dart';
import '../widgets/category_tile.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/message_view.dart';
import '../widgets/status_badge.dart';

/// Shows everything about one item and keeps it up to date while it is open.
///
/// If someone claims or deletes the item on another phone (or in the Firebase
/// console), this screen changes straight away.
class ItemDetailPage extends StatelessWidget {
  /// Creates the detail screen. Use [route] to open it.
  const ItemDetailPage({super.key});

  /// Builds a route to the detail screen of [item].
  ///
  /// The [ItemRepository] is read from the widget tree, where `main.dart`
  /// provides it.
  static Route<void> route(Item item) {
    return MaterialPageRoute<void>(
      builder: (context) {
        final repository = context.read<ItemRepository>();
        return BlocProvider(
          create: (context) => ItemDetailBloc(
            watchItem: WatchItem(repository),
            claimItem: ClaimItem(repository),
            deleteItem: DeleteItem(repository),
            itemId: item.id,
            initialItem: item,
          )..add(const ItemDetailSubscriptionRequested()),
          child: const ItemDetailPage(),
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _delete(BuildContext context, Item item) async {
    final bloc = context.read<ItemDetailBloc>();
    if (await confirmDelete(context, item)) {
      bloc.add(const ItemDetailDeleteRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ItemDetailBloc, ItemDetailState>(
          listenWhen: (previous, current) =>
              previous.claimStatus != current.claimStatus,
          listener: (context, state) {
            switch (state.claimStatus) {
              case ItemActionStatus.success:
                _showSnackBar(context, 'Marked as claimed. Nice work!');
              case ItemActionStatus.failure:
                _showSnackBar(context, state.actionFailure!.message);
              case ItemActionStatus.idle || ItemActionStatus.inProgress:
                break;
            }
          },
        ),
        BlocListener<ItemDetailBloc, ItemDetailState>(
          listenWhen: (previous, current) =>
              previous.deleteStatus != current.deleteStatus,
          listener: (context, state) {
            switch (state.deleteStatus) {
              case ItemActionStatus.success:
                // Grab the messenger first: it belongs to the app, so the
                // snackbar is still shown on the list after this route closes.
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(context).pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Deleted “${state.item?.title}”')),
                );
              case ItemActionStatus.failure:
                _showSnackBar(context, state.actionFailure!.message);
              case ItemActionStatus.idle || ItemActionStatus.inProgress:
                break;
            }
          },
        ),
      ],
      child: BlocBuilder<ItemDetailBloc, ItemDetailState>(
        builder: (context, state) {
          final item = state.item;
          final deleting =
              state.deleteStatus == ItemActionStatus.inProgress ||
              state.deleteStatus == ItemActionStatus.success;
          final removedElsewhere =
              state.status == ItemDetailStatus.removed && !deleting;
          final showItem = item != null && !removedElsewhere;

          return Scaffold(
            appBar: AppBar(
              actions: [
                if (showItem)
                  IconButton(
                    tooltip: 'Delete item',
                    onPressed: state.isBusy
                        ? null
                        : () => _delete(context, item),
                    icon: deleting
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline_rounded),
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: switch (state.status) {
              _ when showItem => _ItemDetails(item: item),
              ItemDetailStatus.removed => Center(
                child: MessageView(
                  icon: Icons.inventory_2_outlined,
                  title: 'This item was removed',
                  message:
                      'Someone deleted it from the board while you were '
                      'looking at it.',
                  actionLabel: 'Back to the list',
                  actionIcon: Icons.arrow_back_rounded,
                  onAction: () => Navigator.of(context).pop(),
                ),
              ),
              ItemDetailStatus.failure => Center(
                child: MessageView(
                  icon: Icons.error_outline_rounded,
                  title: 'Couldn’t load this item',
                  message: state.failure!.message,
                  actionLabel: 'Try again',
                  actionIcon: Icons.refresh_rounded,
                  onAction: () => context.read<ItemDetailBloc>().add(
                    const ItemDetailSubscriptionRequested(),
                  ),
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
            bottomNavigationBar: showItem
                ? _ClaimBar(item: item, claimStatus: state.claimStatus)
                : null,
          );
        },
      ),
    );
  }
}

/// The scrolling body: header, claimed banner, facts and description.
class _ItemDetails extends StatelessWidget {
  const _ItemDetails({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final postedBy = item.postedBy.isEmpty ? 'Anonymous' : item.postedBy;
    final createdAt = item.createdAt;

    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        children: [
          Row(
            children: [
              Hero(
                tag: 'item-${item.id}',
                child: CategoryTile(category: item.category, size: 68),
              ),
              const Spacer(),
              StatusBadge(status: item.status, large: true),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            item.title,
            style: AppTheme.serif(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Posted by $postedBy · ${timeAgo(createdAt)}',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
          ),
          // Slides open when the item is claimed, even if that happened on
          // another device while this screen was open.
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: item.isClaimed
                  ? Padding(
                      key: const ValueKey('claimed'),
                      padding: const EdgeInsets.only(top: 20),
                      child: _ClaimedBanner(claimedAt: item.claimedAt),
                    )
                  : const SizedBox(key: ValueKey('open'), width: 0),
            ),
          ),
          const SizedBox(height: 24),
          _FactsCard(
            facts: [
              (
                icon: ItemCategory.of(item.category).icon,
                label: 'Category',
                value: item.category,
              ),
              (
                icon: Icons.place_outlined,
                label: switch (item.status) {
                  ItemStatus.lost => 'Lost at',
                  ItemStatus.found => 'Found at',
                  ItemStatus.claimed => 'Location',
                },
                value: item.location.isEmpty ? 'Not given' : item.location,
              ),
              (
                icon: Icons.schedule_rounded,
                label: 'Posted',
                value: createdAt == null
                    ? 'Just now'
                    : formatDateTime(createdAt),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'DESCRIPTION',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.description.isEmpty
                ? 'No description was added.'
                : item.description,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 17,
              height: 1.6,
              color: AppColors.ink.withValues(alpha: 0.86),
              fontStyle: item.description.isEmpty ? FontStyle.italic : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// A green note that the item has been returned.
class _ClaimedBanner extends StatelessWidget {
  const _ClaimedBanner({required this.claimedAt});

  final DateTime? claimedAt;

  @override
  Widget build(BuildContext context) {
    const colors = StatusColors.found;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: colors.foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Returned to its owner',
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (claimedAt != null)
                  Text(
                    'Claimed ${formatDateTime(claimedAt!)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.foreground.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A white card listing short facts about the item, one per row.
class _FactsCard extends StatelessWidget {
  const _FactsCard({required this.facts});

  final List<({IconData icon, String label, String value})> facts;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          for (final (index, fact) in facts.indexed) ...[
            if (index > 0)
              const Divider(height: 1, indent: 56, color: AppColors.hairline),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(fact.icon, size: 22, color: AppColors.maroon),
                  const SizedBox(width: 18),
                  Text(
                    fact.label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      fact.value,
                      textAlign: TextAlign.end,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The "Mark as claimed" button pinned to the bottom of the screen.
class _ClaimBar extends StatelessWidget {
  const _ClaimBar({required this.item, required this.claimStatus});

  final Item item;
  final ItemActionStatus claimStatus;

  @override
  Widget build(BuildContext context) {
    final claiming = claimStatus == ItemActionStatus.inProgress;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: item.isClaimed
                ? FilledButton.icon(
                    key: const ValueKey('claimed'),
                    onPressed: null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Claimed'),
                  )
                : FilledButton.icon(
                    key: const ValueKey('claim'),
                    onPressed: claiming
                        ? null
                        : () => context.read<ItemDetailBloc>().add(
                            const ItemDetailClaimRequested(),
                          ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    icon: claiming
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.handshake_outlined),
                    label: Text(claiming ? 'Claiming…' : 'Mark as claimed'),
                  ),
          ),
        ),
      ),
    );
  }
}
