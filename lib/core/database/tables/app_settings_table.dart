import 'package:drift/drift.dart';

class AppSettings extends Table {
  TextColumn get id => text()();
  BoolColumn get onboardingCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get syncEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get theme => text().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
