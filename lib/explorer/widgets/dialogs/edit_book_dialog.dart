// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ztp_projekt/authors/controllers/form/authors_form_state.dart';
import 'package:ztp_projekt/authors/controllers/manage_authors/manage_authors_state.dart';
import 'package:ztp_projekt/authors/controllers/providers.dart';
import 'package:ztp_projekt/authors/models/author.dart';
import 'package:ztp_projekt/books/controllers/form/book_form_state.dart';
import 'package:ztp_projekt/books/controllers/manage_books/manage_books_state.dart';
import 'package:ztp_projekt/books/controllers/providers.dart';
import 'package:ztp_projekt/books/models/book.dart';
import 'package:ztp_projekt/common/widgets/bookshelf_exception_dialog.dart';

class EditBookDialog extends StatefulWidget {
  const EditBookDialog({required this.book, super.key});

  final Book book;

  static Future<void> show(
    BuildContext context,
    Book book,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => EditBookDialog(
        book: book,
      ),
    );
  }

  @override
  State<EditBookDialog> createState() => _EditBookDialogState();
}

class _EditBookDialogState extends State<EditBookDialog> {
  late TextEditingController _titleController;
  late TextEditingController _publisherController;
  late TextEditingController _isbnNumberController;
  late TextEditingController _priceController;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.book.title);
    _publisherController = TextEditingController(text: widget.book.publisher);
    _isbnNumberController = TextEditingController(text: widget.book.isbnNumber);
    _priceController =
        TextEditingController(text: widget.book.price.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final textTheme = Theme.of(context).textTheme;
        final bookFormNotifier = ref.watch(bookFormNotifierProvider.notifier);
        final bookFormState = ref.watch(bookFormNotifierProvider);
        final getAuthorsState = ref.watch(getAuthorsNotifierProvider);

        return WillPopScope(
          onWillPop: () async {
            bookFormNotifier.reset();
            return true;
          },
          child: AlertDialog(
            contentPadding: const EdgeInsets.all(8),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        bookFormNotifier.reset();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 3),
                      child: Text(
                        'Edit book',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            errorText: _titleController.text.isNotEmpty
                                ? null
                                : 'Field cannot be empty',
                          ),
                          onChanged: (title) {
                            bookFormNotifier.updateTitle(title);
                            setState(() {});
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: DropdownButton2<Author>(
                          isExpanded: true,
                          value: bookFormState.author,
                          items: getAuthorsState.authors
                              .map(
                                (author) => DropdownMenuItem<Author>(
                                  onTap: () {},
                                  child: Text(author.fullName),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          controller: _publisherController,
                          decoration: InputDecoration(
                            labelText: 'Publisher',
                            errorText: _publisherController.text.isNotEmpty
                                ? null
                                : 'Field cannot be empty',
                          ),
                          onChanged: (publisher) {
                            bookFormNotifier.updatePublisher(publisher);
                            setState(() {});
                          },
                        ),
                      ),
                      FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          shape: const RoundedRectangleBorder(),
                        ),
                        onPressed: () async {
                          await _editOnPressed(ref, context);
                        },
                        icon: const Icon(
                          Icons.edit,
                        ),
                        label: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editOnPressed(WidgetRef ref, BuildContext context) async {
    final bookFormNotifier = ref.read(bookFormNotifierProvider.notifier);

    if (ref.read(bookFormNotifierProvider).isFormValid) {
      await bookFormNotifier.updateBook();
      if (ref.read(manageBooksNotifierProvider).isException) {
        await BookshelfExceptionDialog.show(
          context,
          ref.read(manageBooksNotifierProvider).getException!,
          () {
            Navigator.of(context).pop();
          },
        );
      } else {
        await ref.read(manageBooksNotifierProvider.notifier).getAll();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _publisherController.dispose();
    _isbnNumberController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}