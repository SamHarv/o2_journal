import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/glass_morphism.dart';
import '../../config/constants.dart';
import '../../data/database/db_helper.dart';
import '../../data/models/entry_model.dart';
import '../../logic/services/date_format_helper.dart';
import 'entry_view.dart';

class HomeView extends StatefulWidget {
  /// The main view of the app, displaying a list of journal entries.
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Database helper instance to interact with the SQLite database
  final db = DatabaseHelper.instance;
  // Number of entries in the database for id generation
  int entryCount = 0;

  @override
  Widget build(BuildContext context) {
    // Hero widget for smooth transitions with background image
    return Hero(
      tag: 'bg',
      child: Scaffold(
        body: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(webbImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: FutureBuilder(
              // Fetches all journal entries from the database
              future: db.readAllEntries(),
              builder: (context, AsyncSnapshot snapshot) {
                // Loading wheel
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                  // Error handling
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                  // No entries found
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return Center(
                    child: GlassMorphism(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No Entries Found.', style: fontStyle),
                      ),
                    ),
                  );
                } else {
                  // Entries found
                  // Get the list of entries from the snapshot
                  final entries = snapshot.data;
                  // Set the entry count for new entry creation
                  entryCount = entries.length;
                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      // Get the entry at the current index
                      final entry = entries[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: InkResponse(
                          borderRadius: BorderRadius.circular(32),
                          onTap: () {
                            // Navigate to the EntryView with the selected entry
                            // and update the state after returning
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EntryView(entry: entry),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 4,
                            ),
                            child: GlassMorphism(
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 0,
                                    ),
                                    child: Text(
                                      // Format the date using the DateFormatHelper
                                      // and display it in the center of the entry
                                      // tile
                                      DateFormatHelper.formatDate(entry.date),
                                      style: fontStyle,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            border: Border.all(color: white, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: FloatingActionButton(
            backgroundColor: black,
            onPressed: () {
              // Create a new entry
              final newEntry = EntryModel(
                // Generate a new ID for the entry (autoincremented in DB)
                id: entryCount,
                // Format date for ordering in the database
                date: DateFormat.yMd().format(DateTime.now()).toString(),
                // Set the content to an empty string
                content: '',
              );
              // Insert the new entry into the database and navigate to the EntryView
              // with the new entry
              // Update the state after returning from the EntryView
              db.createEntry(newEntry).then((_) {
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => EntryView(entry: newEntry),
                  ),
                ).then((_) => setState(() {}));
              });
            },
            child: Icon(Icons.add, color: white),
          ),
        ),
      ),
    );
  }
}
