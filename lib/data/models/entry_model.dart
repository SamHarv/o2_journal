class EntryModel {
  /// [EntryModel] represents a journal entry with an ID, date, and content.

  // The ID is optional as it will be auto-incremented in the database.
  final int? id;
  // The date is a string in the format YYYY/MM/DD.
  String date;
  // The content of the journal entry.
  String content;

  EntryModel({this.id, required this.date, required this.content});

  // Convert a JournalEntry into a Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date, 'content': content};
  }

  // Create a JournalEntry from a Map
  factory EntryModel.fromMap(Map<String, dynamic> map) {
    return EntryModel(
      id: map['id'],
      date: map['date'],
      content: map['content'],
    );
  }
}
