import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:o2_journal/ui/widgets/glass_morphism.dart';

import '../../config/constants.dart';
import '../../data/database/db_helper.dart';
import '../../data/models/entry_model.dart';
import '../../logic/services/date_format_helper.dart';

class EntryView extends StatefulWidget {
  final EntryModel entry;
  const EntryView({super.key, required this.entry});

  @override
  State<EntryView> createState() => _EntryViewState();
}

class _EntryViewState extends State<EntryView> {
  final db = DatabaseHelper.instance;
  late final TextEditingController _contentController;
  final _contentUndoController = UndoHistoryController();

  @override
  void initState() {
    _contentController = TextEditingController(text: widget.entry.content);
    super.initState();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'bg',
      child: Scaffold(
        body: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/webb.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
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
                                  DateFormatHelper.formatDate(
                                    widget.entry.date,
                                  ),
                                  style: fontStyle.copyWith(fontSize: 20),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    undoController: _contentUndoController,
                                    controller: _contentController,
                                    style: fontStyle.copyWith(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Write your entry here...',
                                      hintStyle: fontStyle.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        fontSize: 16,
                                      ),
                                      border: InputBorder.none,
                                    ),
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
              Column(
                children: [
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            widget.entry.content = _contentController.text;
                            // widget.entry.date =
                            //     DateFormat.yMd()
                            //         .format(DateTime.now())
                            //         .toString();
                            db.updateEntry(
                              EntryModel(
                                id: widget.entry.id,
                                date: widget.entry.date,
                                content: _contentController.text,
                              ),
                            );
                            setState(() {});
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Row(
                          children: [
                            // Save button
                            IconButton(
                              icon: const Icon(Icons.save, color: Colors.white),
                              onPressed: () {
                                widget.entry.content = _contentController.text;
                                widget.entry.date =
                                    DateFormat.yMd()
                                        .format(DateTime.now())
                                        .toString();
                                db.updateEntry(
                                  EntryModel(
                                    id: widget.entry.id,
                                    date: widget.entry.date,
                                    content: _contentController.text,
                                  ),
                                );

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.black,
                                      title: const Text(
                                        'Entry Saved',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'OK',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
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
                              icon: const Icon(Icons.undo, color: Colors.white),
                              onPressed: () => _contentUndoController.undo(),
                            ),
                            // Redo typing
                            IconButton(
                              icon: const Icon(Icons.redo, color: Colors.white),
                              onPressed: () => _contentUndoController.redo(),
                            ),
                            // Delete entry
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // Show dialog to confirm deletion
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => StatefulBuilder(
                                        builder: (context, state) {
                                          return AlertDialog(
                                            backgroundColor: Colors.black,
                                            title: const Text(
                                              'Delete Entry',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            content: const Text(
                                              'Are you sure you want to delete this entry?',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  db.deleteEntry(
                                                    widget.entry.id!,
                                                  );

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
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
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
      ),
    );
  }
}
