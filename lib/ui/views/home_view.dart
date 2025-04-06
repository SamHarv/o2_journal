import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:o2_journal/ui/widgets/glass_morphism.dart';

import '../../config/constants.dart';
import '../../data/database/db_helper.dart';
import '../../data/models/entry_model.dart';
import '../../logic/services/date_format_helper.dart';
import 'entry_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final db = DatabaseHelper.instance;
  int entryCount = 0;

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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: FutureBuilder(
              future: db.readAllEntries(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
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
                  final entries = snapshot.data;
                  entryCount = entries.length;
                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: InkResponse(
                          borderRadius: BorderRadius.circular(32),
                          onTap: () {
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
                                      DateFormatHelper.formatDate(entry.date),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
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
            border: Border.all(color: Colors.white, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),

          child: FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              // Create a new entry
              final newEntry = EntryModel(
                id: entryCount,
                date: DateFormat.yMd().format(DateTime.now()).toString(),
                // date: DateFormat.yMd().format(DateTime(2023)).toString(),
                content: '',
              );

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
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
