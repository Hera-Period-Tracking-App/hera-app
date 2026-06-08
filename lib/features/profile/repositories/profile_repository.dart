import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/profile/datasources/profile_local_datasource.dart';
import 'package:hera_app/features/profile/models/profile_settings_summary.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(profileLocalDataSourceProvider)),
);

class ProfileRepository {
  const ProfileRepository(this._dataSource);

  final ProfileLocalDataSource _dataSource;

  Stream<ProfileSettingsSummary> watchSettingsSummary() {
    return _dataSource.watchUserSettings().map(
          (row) => ProfileSettingsSummary(
            averageCycleLength: row?.averageCycleLength,
            averageMenstruationLength: row?.averageMenstruationLength,
          ),
        );
  }
}
