import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/database/app_database.dart';

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>(
  (ref) => ProfileLocalDataSource(ref.watch(appDatabaseProvider)),
);

class ProfileLocalDataSource {
  const ProfileLocalDataSource(this._database);

  final AppDatabase _database;

  Stream<UserSetting?> watchUserSettings() {
    return (_database.select(_database.userSettings)
          ..where((row) => row.id.equals('default')))
        .watchSingleOrNull();
  }
}
