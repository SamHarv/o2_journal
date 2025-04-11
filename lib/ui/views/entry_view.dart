import 'package:flutter/material.dart';
import 'package:o2_journal/ui/widgets/background_image.dart';

import '../widgets/glass_morphism.dart';
import '../../config/constants.dart';
import '../../data/database/db_helper.dart';
import '../../data/models/entry_model.dart';
import '../../logic/services/date_format_helper.dart';

class EntryView extends StatefulWidget {
  /// The view for a single journal entry, allowing editing and deletion.
  // [entry] is the journal entry to be displayed and edited.
  final EntryModel entry;
  const EntryView({super.key, required this.entry});

  @override
  State<EntryView> createState() => _EntryViewState();
}

class _EntryViewState extends State<EntryView> {
  // Database helper instance to interact with the SQLite database
  final db = DatabaseHelper.instance;
  // TextEditingController for the content of the journal entry
  late final TextEditingController _contentController;
  // UndoController for managing undo/redo actions in the text field
  final _contentUndoController = UndoHistoryController();

  @override
  void initState() {
    // Initialise the TextEditingController with the current entry content
    _contentController = TextEditingController(text: widget.entry.content);
    super.initState();
  }

  @override
  void dispose() {
    // Dispose of the TextEditingController when the widget is removed from the widget tree
    _contentController.dispose();
    _contentUndoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hero widget for smooth transitions with background image
    return Scaffold(
      backgroundColor: black,
      body: BackgroundImage(
        child: Stack(
          children: [
            Column(
              children: [
                // SizedBox to allow space for imaginary app bar
                SizedBox(height: 90),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GlassMorphism(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // Display the formatted date of the journal entry
                                DateFormatHelper.formatDate(widget.entry.date),
                                style: fontStyle,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: TextField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  undoController: _contentUndoController,
                                  controller: _contentController,
                                  // Smaller font for content
                                  style: fontStyle.copyWith(fontSize: 16),
                                  decoration: InputDecoration(
                                    hintText: 'Write your entry here...',
                                    hintStyle: fontStyle.copyWith(
                                      color: white.withValues(alpha: 0.5),
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  // Multiline text field
                                  maxLines: null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Custome App bar with save, undo, redo, and delete buttons
            Column(
              children: [
                // Space for status bar
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Update content, but not date
                          widget.entry.content = _contentController.text;
                          // Update in DB
                          db.updateEntry(
                            EntryModel(
                              id: widget.entry.id,
                              date: widget.entry.date,
                              //"0${widget.entry.date}",
                              content: _contentController.text,
                            ),
                          );
                          // Navigate back to home view
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back, color: white),
                      ),
                      Row(
                        children: [
                          // Save button
                          IconButton(
                            icon: const Icon(Icons.save, color: white),
                            onPressed: () {
                              // Update content, but not date
                              widget.entry.content = _contentController.text;
                              // Update in DB
                              db.updateEntry(
                                EntryModel(
                                  id: widget.entry.id,
                                  date: widget.entry.date,
                                  content: _contentController.text,
                                ),
                              );
                              // Confirm saved
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: black,
                                    title: const Text(
                                      'Entry Saved',
                                      style: TextStyle(color: white),
                                    ),
                                    actions: [
                                      TextButton(
                                        // Close dialog
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'OK',
                                          style: TextStyle(color: white),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          // Undo typing
                          IconButton(
                            icon: const Icon(Icons.undo, color: white),
                            onPressed: () => _contentUndoController.undo(),
                          ),
                          // Redo typing
                          IconButton(
                            icon: const Icon(Icons.redo, color: white),
                            onPressed: () => _contentUndoController.redo(),
                          ),
                          // Delete entry
                          IconButton(
                            icon: const Icon(Icons.delete, color: white),
                            onPressed: () {
                              // Show dialog to confirm deletion
                              showDialog(
                                context: context,
                                builder:
                                    (context) => StatefulBuilder(
                                      builder: (context, state) {
                                        return AlertDialog(
                                          backgroundColor: black,
                                          title: const Text(
                                            'Delete Entry',
                                            style: TextStyle(color: white),
                                          ),
                                          content: const Text(
                                            'Are you sure you want to delete this entry?',
                                            style: TextStyle(color: white),
                                          ),
                                          actions: [
                                            // Delete button
                                            TextButton(
                                              onPressed: () {
                                                // Delete entry from DB
                                                db.deleteEntry(
                                                  widget.entry.id!,
                                                );
                                                // Pop the dialog
                                                // Return to home view
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                            // Cancel deletion button
                                            TextButton(
                                              // Close dialog
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(color: white),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
