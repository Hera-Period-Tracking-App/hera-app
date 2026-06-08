import 'package:drift/drift.dart';

class NoteEntries extends Table {
  TextColumn get id => text()();
  TextColumn get cycleId => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get encryptedContent => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
