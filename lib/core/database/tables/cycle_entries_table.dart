import 'package:drift/drift.dart';

class CycleEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get startDateLocal => dateTime()();
  IntColumn get cycleLength => integer()();
  IntColumn get menstruationLength => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
