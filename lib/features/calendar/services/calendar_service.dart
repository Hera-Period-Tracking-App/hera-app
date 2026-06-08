import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/calendar/models/calendar_day_view.dart';

final calendarServiceProvider = Provider<CalendarService>(
  (ref) => const CalendarService(),
);

class CalendarService {
  const CalendarService();

  Future<List<CalendarDayView>> buildMonthView() async {
    return const [];
  }
}
