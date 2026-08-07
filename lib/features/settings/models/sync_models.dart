class EncryptedSyncRecord {
  const EncryptedSyncRecord({
    required this.id,
    required this.ciphertext,
    required this.updatedAtUtc,
    required this.isDeleted,
    this.originDeviceId,
  });

  final Object id;
  final String? ciphertext;
  final DateTime updatedAtUtc;
  final bool isDeleted;
  final String? originDeviceId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ciphertext': ciphertext,
      'updatedAtUtc': updatedAtUtc.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
      'originDeviceId': originDeviceId,
    };
  }

  factory EncryptedSyncRecord.fromJson(Map<String, dynamic> json) {
    return EncryptedSyncRecord(
      id: json['id'] ?? '',
      ciphertext: json['ciphertext'] as String?,
      updatedAtUtc: DateTime.parse(json['updatedAtUtc'] as String).toUtc(),
      isDeleted: json['isDeleted'] as bool? ?? false,
      originDeviceId: json['originDeviceId'] as String?,
    );
  }
}

class SyncDownloadResult {
  const SyncDownloadResult({
    required this.cursor,
    required this.wrappedMasterKey,
    required this.userSettings,
    required this.cycles,
    required this.notes,
    required this.appSettings,
  });

  final String? cursor;
  final String? wrappedMasterKey;
  final List<EncryptedSyncRecord> userSettings;
  final List<EncryptedSyncRecord> cycles;
  final List<EncryptedSyncRecord> notes;
  final List<EncryptedSyncRecord> appSettings;

  factory SyncDownloadResult.fromJson(Map<String, dynamic> json) {
    return SyncDownloadResult(
      cursor: json['cursor'] as String?,
      wrappedMasterKey: json['wrappedMasterKey'] as String?,
      userSettings: _parseRecords(json['userSettings']),
      cycles: _parseRecords(json['cycles']),
      notes: _parseRecords(json['notes']),
      appSettings: _parseRecords(json['appSettings']),
    );
  }

  int get totalCount =>
      userSettings.length + cycles.length + notes.length + appSettings.length;
}

class SyncUploadPayload {
  const SyncUploadPayload({
    required this.deviceId,
    this.wrappedMasterKey,
    this.userSettings = const [],
    this.cycles = const [],
    this.notes = const [],
    this.appSettings = const [],
  });

  final String deviceId;
  final String? wrappedMasterKey;
  final List<EncryptedSyncRecord> userSettings;
  final List<EncryptedSyncRecord> cycles;
  final List<EncryptedSyncRecord> notes;
  final List<EncryptedSyncRecord> appSettings;

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      if (wrappedMasterKey != null && wrappedMasterKey!.isNotEmpty)
        'wrappedMasterKey': wrappedMasterKey,
      'userSettings': userSettings.map((record) => record.toJson()).toList(growable: false),
      'cycles': cycles.map((record) => record.toJson()).toList(growable: false),
      'notes': notes.map((record) => record.toJson()).toList(growable: false),
      'appSettings': appSettings.map((record) => record.toJson()).toList(growable: false),
    };
  }
}

class SyncUploadResult {
  const SyncUploadResult({
    this.cursor,
    this.acceptedCount,
    this.ignoredCount,
    this.raw = const {},
  });

  final String? cursor;
  final int? acceptedCount;
  final int? ignoredCount;
  final Map<String, dynamic> raw;

  factory SyncUploadResult.fromJson(Map<String, dynamic> json) {
    return SyncUploadResult(
      cursor: json['cursor'] as String?,
      acceptedCount: _readInt(json['acceptedCount']),
      ignoredCount: _readInt(json['ignoredCount']),
      raw: json,
    );
  }
}

List<EncryptedSyncRecord> _parseRecords(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value
      .whereType<Map<String, dynamic>>()
      .map(EncryptedSyncRecord.fromJson)
      .toList(growable: false);
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}
