import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/calendar/models/calendar_day_view.dart';
import 'package:hera_app/features/calendar/repositories/calendar_repository.dart';

final calendarProvider = AsyncNotifierProvider<CalendarNotifier, List<CalendarDayView>> (CalendarNotifier.new);

class CalendarNotifier extends AsyncNotifier<List<CalendarDayView>> {
  @override
  Future<List<CalendarDayView>> build() {
    return ref.read(calendarRepositoryProvider).getMonthView();
  }
}
