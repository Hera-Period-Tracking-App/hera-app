import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_day_view.freezed.dart';
part 'calendar_day_view.g.dart';

@freezed
abstract class CalendarDayView with _$CalendarDayView {
  const factory CalendarDayView({
    required DateTime date,
    required bool hasCycleEntry,
    required bool hasNotes,
    required bool hasSymptoms,
  }) = _CalendarDayView;

  factory CalendarDayView.fromJson(Map<String, dynamic> json) => _$CalendarDayViewFromJson(json);
}
