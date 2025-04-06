import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/entry_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Get database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('journal.db');
    return _database!;
  }

  // Initialise database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create tables
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE journal_entries(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      content TEXT NOT NULL
    )
    ''');
  }

  // Create - Add a new journal entry
  Future<int> createEntry(EntryModel entry) async {
    final db = await instance.database;
    return await db.insert('journal_entries', entry.toMap());
  }

  // Read - Get a single journal entry by ID
  Future<EntryModel> readEntry(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'journal_entries',
      columns: ['id', 'date', 'content'],
      where: 'id = ?',
      whereArgs: [id],
    );

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
    return result.map((map) => EntryModel.fromMap(map)).toList();
  }

  // Update - Modify an existing journal entry
  Future<int> updateEntry(EntryModel entry) async {
    final db = await instance.database;
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
    return await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  // Delete all entries - useful for testing or reset functionality
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
