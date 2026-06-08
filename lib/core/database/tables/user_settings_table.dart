import 'package:drift/drift.dart';

class UserSettings extends Table {
  TextColumn get id => text()();
  IntColumn get averageCycleLength => integer().nullable()();
  IntColumn get averageMenstruationLength => integer().nullable()();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get biometricEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get notesEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get aiEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get privacyMode => text().withLength(min: 1, max: 32)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
