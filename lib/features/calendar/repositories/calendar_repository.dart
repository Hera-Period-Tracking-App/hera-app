import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/calendar/models/calendar_day_view.dart';
import 'package:hera_app/features/calendar/services/calendar_service.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>(
  (ref) => CalendarRepository(ref.watch(calendarServiceProvider)),
);

class CalendarRepository {
  CalendarRepository(this._service);

  final CalendarService _service;

  Future<List<CalendarDayView>> getMonthView() {
    return _service.buildMonthView();
  }
}
