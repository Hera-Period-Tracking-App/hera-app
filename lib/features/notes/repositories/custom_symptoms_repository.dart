import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';

final customSymptomsRepositoryProvider = Provider<CustomSymptomsRepository>(
  (ref) => CustomSymptomsRepository(ref.watch(secureStorageDataSourceProvider)),
);

class CustomSymptomsRepository {
  const CustomSymptomsRepository(this._storage);
  final SecureStorageDataSource _storage;

  Future<Set<String>> load() async {
    final raw = await _storage.read(AppConstants.customSymptomsKey);
    if (raw == null || raw.isEmpty) return <String>{};
    final decoded = jsonDecode(raw);
    return decoded is List ? decoded.whereType<String>().map((item) => item.trim()).where((item) => item.isNotEmpty).toSet() : <String>{};
  }

  Future<void> save(Set<String> symptoms) {
    final values = symptoms.map((item) => item.trim()).where((item) => item.isNotEmpty).toSet().toList()..sort();
    return _storage.write(AppConstants.customSymptomsKey, jsonEncode(values));
  }
}
