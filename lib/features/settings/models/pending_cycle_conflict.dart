import 'package:hera_app/core/database/app_database.dart';

enum CycleConflictChoice { local, remote }

class PendingCycleConflict {
  const PendingCycleConflict({
    required this.id,
    required this.localCycle,
    required this.remoteCycle,
    required this.createdAtUtc,
  });

  final String id;
  final SyncCycleSnapshot localCycle;
  final SyncCycleSnapshot remoteCycle;
  final DateTime createdAtUtc;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localCycle': localCycle.toJson(),
      'remoteCycle': remoteCycle.toJson(),
      'createdAtUtc': createdAtUtc.toUtc().toIso8601String(),
    };
  }

  factory PendingCycleConflict.fromJson(Map<String, dynamic> json) {
    return PendingCycleConflict(
      id: json['id'] as String? ?? '',
      localCycle: SyncCycleSnapshot.fromJson(
        json['localCycle'] as Map<String, dynamic>? ?? const {},
      ),
      remoteCycle: SyncCycleSnapshot.fromJson(
        json['remoteCycle'] as Map<String, dynamic>? ?? const {},
      ),
      createdAtUtc: DateTime.tryParse(json['createdAtUtc'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

class SyncCycleSnapshot {
  const SyncCycleSnapshot({
    required this.id,
    required this.startDate,
    required this.cycleLength,
    required this.menstruationLength,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DateTime startDate;
  final int cycleLength;
  final int menstruationLength;
  final DateTime createdAt;
  final DateTime updatedAt;

  DateTime get endDate => startDate.add(Duration(days: cycleLength - 1));

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'cycleLength': cycleLength,
      'menstruationLength': menstruationLength,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SyncCycleSnapshot.fromJson(Map<String, dynamic> json) {
    return SyncCycleSnapshot(
      id: json['id'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      cycleLength: json['cycleLength'] as int? ?? 28,
      menstruationLength: json['menstruationLength'] as int? ?? 5,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  factory SyncCycleSnapshot.fromEntry(CycleEntry entry) {
    return SyncCycleSnapshot(
      id: entry.id,
      startDate: DateTime(
        entry.startDateLocal.year,
        entry.startDateLocal.month,
        entry.startDateLocal.day,
      ),
      cycleLength: entry.cycleLength,
      menstruationLength: entry.menstruationLength,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }
}
