import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// The "Search by title" box above the list.
///
/// It owns its [TextEditingController] and stays in sync with [query], so
/// clearing the search from elsewhere (for example, the "Clear filters"
/// button) also empties the box.
class ItemSearchField extends StatefulWidget {
  /// Creates a search field showing [query] that reports edits to [onChanged].
  const ItemSearchField({
    super.key,
    required this.query,
    required this.onChanged,
  });

  /// The current search text, as stored in the bloc.
  final String query;

  /// Called with the new text on every keystroke.
  final ValueChanged<String> onChanged;

  @override
  State<ItemSearchField> createState() => _ItemSearchFieldState();
}

class _ItemSearchFieldState extends State<ItemSearchField> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void didUpdateWidget(ItemSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        hintText: 'Search by title',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
        // Rebuild only the clear button as the text changes.
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.close_rounded),
              onPressed: _clear,
            );
          },
        ),
      ),
    );
  }
}
