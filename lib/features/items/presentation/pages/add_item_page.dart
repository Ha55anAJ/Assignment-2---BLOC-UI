import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/usecases/add_item.dart';
import '../bloc/add_item/add_item_bloc.dart';
import '../utils/item_category.dart';

/// The "Post an item" form. Use [route] to open it.
///
/// Field validation follows the Flutter cookbook recipe "Build a form with
/// validation": a [Form] with a [GlobalKey], and a `validator` on each field.
class AddItemPage extends StatelessWidget {
  /// Creates the form screen.
  const AddItemPage({super.key});

  /// Builds a route to the form.
  ///
  /// The [ItemRepository] is read from the widget tree, where `main.dart`
  /// provides it.
  static Route<void> route() {
    return MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) =>
            AddItemBloc(addItem: AddItem(context.read<ItemRepository>())),
        child: const AddItemPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddItemBloc, AddItemState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
        switch (state.status) {
          case AddItemStatus.success:
            Navigator.of(context).pop();
            messenger.showSnackBar(
              const SnackBar(content: Text('Posted! It’s on the board now.')),
            );
          case AddItemStatus.failure:
            messenger.showSnackBar(
              SnackBar(content: Text(state.failure!.message)),
            );
          case AddItemStatus.initial || AddItemStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Post an item')),
        body: const SafeArea(child: AddItemForm()),
      ),
    );
  }
}

/// The fields of the "Post an item" form and its submit button.
class AddItemForm extends StatefulWidget {
  /// Creates the form.
  const AddItemForm({super.key});

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

// Create a corresponding State class.
// This class holds data related to the form.
class _AddItemFormState extends State<AddItemForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<_AddItemFormState>.
  final _formKey = GlobalKey<FormState>();

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _postedByController = TextEditingController();

  ItemStatus _status = ItemStatus.found;
  String? _category;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _postedByController.dispose();
    super.dispose();
  }

  /// Returns an error message if [value] is blank.
  String? Function(String?) _required(String message) {
    // The validator receives the text that the user has entered.
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  void _submit() {
    // Validate returns true if the form is valid, or false otherwise.
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    context.read<AddItemBloc>().add(
      AddItemSubmitted(
        ItemDraft(
          title: _titleController.text,
          category: _category!,
          location: _locationController.text,
          status: _status,
          description: _descriptionController.text,
          postedBy: _postedByController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final submitting = context.select(
      (AddItemBloc bloc) => bloc.state.status == AddItemStatus.submitting,
    );

    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'What happened?',
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<ItemStatus>(
            segments: const [
              ButtonSegment(
                value: ItemStatus.found,
                icon: Icon(Icons.volunteer_activism_outlined),
                label: Text('I found something'),
              ),
              ButtonSegment(
                value: ItemStatus.lost,
                icon: Icon(Icons.travel_explore_rounded),
                label: Text('I lost something'),
              ),
            ],
            selected: {_status},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                setState(() => _status = selection.single),
            style: SegmentedButton.styleFrom(
              backgroundColor: AppColors.surface,
              selectedBackgroundColor: AppColors.maroon,
              selectedForegroundColor: Colors.white,
              side: const BorderSide(color: AppColors.hairline),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _titleController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            maxLength: 60,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Black Backpack',
            ),
            validator: _required('Give the item a short title'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            borderRadius: BorderRadius.circular(16),
            items: [
              for (final category in ItemCategory.all)
                DropdownMenuItem(
                  value: category.name,
                  child: Row(
                    children: [
                      Icon(
                        category.icon,
                        size: 20,
                        color: category.colors.foreground,
                      ),
                      const SizedBox(width: 12),
                      Text(category.name),
                    ],
                  ),
                ),
            ],
            onChanged: (value) => setState(() => _category = value),
            validator: (value) => value == null ? 'Pick a category' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _locationController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: _status == ItemStatus.lost
                  ? 'Where did you lose it?'
                  : 'Where did you find it?',
              hintText: 'e.g. Library, 2nd Floor',
              prefixIcon: const Icon(Icons.place_outlined),
            ),
            validator: _required('Say where on campus'),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 3,
            maxLines: 6,
            maxLength: 300,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Colour, brand, anything that helps the owner know it',
              alignLabelWithHint: true,
            ),
            validator: _required('Add a short description'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _postedByController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Your name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: _required('Let people know who to contact'),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: submitting ? null : _submit,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: submitting
                  ? const SizedBox.square(
                      key: ValueKey('progress'),
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Text('Post item', key: ValueKey('label')),
            ),
          ),
        ],
      ),
    );
  }
}
