import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/database/tables/app_settings_table.dart';
import 'package:hera_app/core/database/tables/cycle_entries_table.dart';
import 'package:hera_app/core/database/tables/note_entries_table.dart';
import 'package:hera_app/core/database/tables/user_settings_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

part 'app_database.g.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

@DriftDatabase(
  tables: [
    CycleEntries,
    NoteEntries,
    UserSettings,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
    await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();

    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'hera.sqlite'));

    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
    final encryptionKey =
        await _readOrCreateDbEncryptionKey(storage: storage);

    return NativeDatabase(
      file,
      setup: (database) {
        database.execute("PRAGMA key = '$encryptionKey';");
      },
    );
  });
}

Future<String> _readOrCreateDbEncryptionKey({
  required FlutterSecureStorage storage,
}) async {
  final existingKey = await storage.read(key: AppConstants.sqlCipherKey);
  if (existingKey != null && existingKey.isNotEmpty) {
    return existingKey;
  }

  final key = _generateSqlCipherKey();
  await storage.write(key: AppConstants.sqlCipherKey, value: key);
  return key;
}

String _generateSqlCipherKey() {
  final random = Random.secure();
  const charset =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(64, (_) => charset[random.nextInt(charset.length)])
      .join();
}
