class EntryModel {
  final int? id;
  String date;
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

  @override
  String toString() {
    return 'JournalEntry(id: $id, date: $date, content: $content)';
  }
}
