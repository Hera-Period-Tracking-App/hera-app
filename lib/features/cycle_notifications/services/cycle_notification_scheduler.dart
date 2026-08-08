import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/datasources/notification_data_source.dart';
import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';

final cycleNotificationSchedulerProvider = Provider<CycleNotificationScheduler>(
  (ref) =>
      CycleNotificationScheduler(ref.watch(notificationDataSourceProvider)),
);

class CycleNotificationScheduler {
  const CycleNotificationScheduler(this._notifications);

  static const int _cycleCount = 3;
  static const int _baseId = 41000;
  static const int _idsPerCycle = 10;
  static bool _debugTestScheduled = false;

  final NotificationDataSource _notifications;

  List<int> get notificationIds => [
        for (var cycleIndex = 0; cycleIndex < _cycleCount; cycleIndex++)
          for (var offset = 0; offset < _idsPerCycle; offset++)
            _baseId + (cycleIndex * _idsPerCycle) + offset,
      ];

  Future<void> reschedule({
    required List<CycleSummary> cycles,
    required CycleForecast? forecast,
    required bool enabled,
  }) async {
    await _notifications.cancelMany(notificationIds);

    if (!enabled) {
      return;
    }

    final permissionsGranted = await _notifications.requestPermissions();
    if (!permissionsGranted) {
      return;
    }

    await _scheduleDebugTestNotification();

    if (cycles.isEmpty || forecast == null) {
      return;
    }

    final sortedCycles = [...cycles]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final latestCycleStart = _dateOnly(sortedCycles.last.startDate);

    for (var cycleIndex = 0; cycleIndex < _cycleCount; cycleIndex++) {
      final cycleStart = latestCycleStart.add(
        Duration(days: forecast.cycleLength * cycleIndex),
      );
      final nextPeriod = cycleStart.add(Duration(days: forecast.cycleLength));
      final ovulation =
          cycleStart.add(Duration(days: forecast.ovulationDay - 1));
      final fertileWindowStart = ovulation.subtract(const Duration(days: 5));
      final lutealStart = ovulation.add(const Duration(days: 1));
      final baseId = _baseId + (cycleIndex * _idsPerCycle);

      await _scheduleMorningReminder(
        id: baseId,
        date: nextPeriod.subtract(const Duration(days: 2)),
        title: 'Your period may start soon',
        body: 'Based on your cycle, menstruation may begin in 2 days.',
        payload: 'period_soon',
      );
      await _scheduleMorningReminder(
        id: baseId + 1,
        date: nextPeriod,
        title: 'Menstruation may start today',
        body: 'Your predicted period starts today.',
        payload: 'period_start',
      );
      await _scheduleMorningReminder(
        id: baseId + 2,
        date: ovulation.subtract(const Duration(days: 1)),
        title: 'Ovulation may be tomorrow',
        body: 'Your predicted ovulation day is coming up.',
        payload: 'ovulation_soon',
      );
      await _scheduleMorningReminder(
        id: baseId + 3,
        date: ovulation,
        title: 'Predicted ovulation today',
        body: 'Today may be your ovulation day.',
        payload: 'ovulation_today',
      );
      await _scheduleMorningReminder(
        id: baseId + 4,
        date: fertileWindowStart,
        title: 'Fertile window may begin today',
        body: 'Your predicted fertile window starts today.',
        payload: 'fertile_window_start',
      );
      await _scheduleMorningReminder(
        id: baseId + 5,
        date: lutealStart,
        title: 'Luteal phase may begin today',
        body: 'Your cycle may be entering the luteal phase.',
        payload: 'luteal_start',
      );
    }
  }

  Future<void> cancelCycleNotifications() {
    return _notifications.cancelMany(notificationIds);
  }

  Future<void> _scheduleDebugTestNotification() async {
    if (!kDebugMode || _debugTestScheduled) {
      return;
    }
    _debugTestScheduled = true;

    await _notifications.showNow(
      id: 49998,
      title: 'Hera notification test',
      body: 'Immediate notifications are working.',
      payload: 'test_notification_now',
    );

    var scheduleStatus = 'registered';
    try {
      await _notifications.schedule(
        id: 49999,
        date: DateTime.now().add(const Duration(seconds: 30)),
        title: 'Hera scheduled test',
        body: 'Exact debug scheduled notifications are working.',
        exact: true,
        payload: 'test_notification_scheduled',
      );
    } catch (error) {
      scheduleStatus = error.toString();
    }

    final pending = await _notifications.pendingNotificationRequests();
    await _notifications.showNow(
      id: 49997,
      title: 'Hera schedule diagnostics',
      body: 'Schedule: $scheduleStatus. Pending: ${pending.length}.',
      payload: 'test_notification_diagnostics',
    );

    Timer(const Duration(seconds: 10), () {
      _notifications.showNow(
        id: 49996,
        title: 'Hera delayed in-app test',
        body: 'The app can show delayed notifications while running.',
        payload: 'test_notification_timer',
      );
    });
  }

  Future<void> _scheduleMorningReminder({
    required int id,
    required DateTime date,
    required String title,
    required String body,
    required String payload,
  }) {
    final morningDate = DateTime(date.year, date.month, date.day, 9);
    return _notifications.schedule(
      id: id,
      date: morningDate,
      title: title,
      body: body,
      payload: payload,
    );
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
