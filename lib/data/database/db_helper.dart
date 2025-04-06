import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/entry_model.dart';

class DatabaseHelper {
  /// [DatabaseHelper] is a singleton class that manages the SQLite database for the journal app.

  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  // Get database
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialise the database if it is null
    _database = await _initDB('journal.db');
    return _database!;
  }

  // Initialise database
  Future<Database> _initDB(String filePath) async {
    // Get the path to the database file
    final dbPath = await getDatabasesPath();
    // Join the database path with the file name
    final path = join(dbPath, filePath);
    // Open the database and create it if it doesn't exist
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create tables
  Future _createDB(Database db, int version) async {
    // Create the journal_entries table
    await db.execute('''
    CREATE TABLE journal_entries(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      content TEXT NOT NULL
    )
    ''');
  }

  // Create a new journal entry in the database
  Future<int> createEntry(EntryModel entry) async {
    final db = await instance.database;
    // Insert the entry into the journal_entries table
    return await db.insert('journal_entries', entry.toMap());
  }

  // Read - Get a single journal entry by ID
  Future<EntryModel> readEntry(int id) async {
    final db = await instance.database;
    // Query the journal_entries table for the entry with the given ID
    final maps = await db.query(
      'journal_entries',
      columns: ['id', 'date', 'content'],
      // Use the ID to filter the results
      where: 'id = ?',
      whereArgs: [id],
    );
    // If the entry exists, return it as an EntryModel
    if (maps.isNotEmpty) {
      return EntryModel.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  // Read - Get all journal entries sorted by date (most recent first)
  Future<List<EntryModel>> readAllEntries() async {
    final db = await instance.database;
    // format = YYYY/MM/DD
    final result = await db.query('journal_entries', orderBy: 'date DESC');
    // Map the result to a list of EntryModel objects
    return result.map((map) => EntryModel.fromMap(map)).toList();
  }

  // Update - Modify an existing journal entry
  Future<int> updateEntry(EntryModel entry) async {
    final db = await instance.database;
    // Update the journal_entries table with the new values
    return await db.update(
      'journal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // Delete - Remove a journal entry
  Future<int> deleteEntry(int id) async {
    final db = await instance.database;
    // Delete the entry from the journal_entries table with the given ID
    return await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  // Delete all entries
  Future<int> deleteAllEntries() async {
    final db = await instance.database;
    return await db.delete('journal_entries');
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
