import 'package:freezed_annotation/freezed_annotation.dart';

part 'cycle_summary.freezed.dart';
part 'cycle_summary.g.dart';

@freezed
abstract class CycleSummary with _$CycleSummary {
  const factory CycleSummary({
    required String id,
    required DateTime startDate,
    int? cycleLength,
    int? menstruationLength,
  }) = _CycleSummary;

  factory CycleSummary.fromJson(Map<String, dynamic> json) => _$CycleSummaryFromJson(json);
}
