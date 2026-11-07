import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hera_app/core/datasources/notification_data_source.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/cycle_notifications/services/cycle_notification_scheduler.dart';
import 'package:hera_app/features/cycles/datasources/cycle_local_datasource.dart';
import 'package:integration_test/integration_test.dart';

import 'support/test_environment.dart';

/// TC-005 / F-05 / TCI-05: SQLite -> scheduler -> native notification plugin.
/// Predpogoj: namenska Android naprava z dovoljenimi obvestili.
/// Podatki iz specifikacije: začetek danes + 60 dni, napoved 28/14/5.
/// Prihodnji cikel je testna priprava prek datasource (UI ga upravičeno zavrne).
/// Preverimo vse tri datume ob 09:00 in dejanske čakajoče OS zahteve.
/// Ne preverjamo dostave obvestil ob prihodnjem času.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-005: registriraj tri opomnike period_soon v sistemu', (tester) async {
    final env = TestEnvironment();
    final notifications = ObservedNotifications(env.storage);
    final scheduler = CycleNotificationScheduler(notifications, debugDiagnosticsEnabled: false);
    addTearDown(() async {
      try {
        await notifications.cancelMany(scheduler.notificationIds);
      } finally {
        await env.dispose(tester);
      }
    });
    await env.initialize();
    expect(await notifications.notificationsEnabled(), isTrue,
        reason: 'Pred zagonom omogoči obvestila na namenskem testnem emulatorju.');
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).add(const Duration(days: 60));
    await CycleLocalDataSource(env.database).insertCycleEntry(
      startDate: start,
      cycleLength: 28,
      menstruationLength: 5,
    );
    final cycles = await env.cycles.watchSummaries().first;
    expect(cycles, hasLength(1));
    expect(cycles.single.startDate, start);
    expect(cycles.single.cycleLength, 28);
    expect(cycles.single.menstruationLength, 5);
    expect(
        await scheduler.reschedule(
          cycles: cycles,
          forecast: const CycleForecast(cycleLength: 28, ovulationDay: 14, menstruationLength: 5),
          enabled: true,
        ),
        isTrue);

    final reminders = notifications.scheduled.where((item) => item.payload == 'period_soon').toList();
    expect(reminders, hasLength(3));
    final pending = await notifications.pendingNotificationRequests();
    expect(pending.where((item) => item.payload == 'period_soon'), hasLength(3));
    for (var index = 0; index < 3; index++) {
      final reminder = reminders[index];
      final day = start.add(Duration(days: 26 + 28 * index));
      expect(reminder.date, DateTime(day.year, day.month, day.day, 9));
      expect(reminder.title, 'Your period may start soon');
      final registered = pending.singleWhere((item) => item.id == reminder.id);
      expect(registered.payload, 'period_soon');
      expect(registered.title, reminder.title);
    }
  });
}

/// Records the schedule arguments, while still executing the real native call.
/// PendingNotificationRequest does not expose the scheduled date.
class ObservedNotifications extends NotificationDataSource {
  ObservedNotifications(SecureStorageDataSource storage) : super(FlutterLocalNotificationsPlugin(), storage);

  final scheduled = <({int id, DateTime date, String title, String? payload})>[];

  @override
  Future<void> schedule(
      {required int id,
      required DateTime date,
      required String title,
      required String body,
      bool exact = false,
      String? payload}) async {
    await super.schedule(id: id, date: date, title: title, body: body, exact: exact, payload: payload);
    scheduled.add((id: id, date: date, title: title, payload: payload));
  }
}
