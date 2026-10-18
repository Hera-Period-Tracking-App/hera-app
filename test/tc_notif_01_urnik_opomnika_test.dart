import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hera_app/core/datasources/notification_data_source.dart';
import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/cycle_notifications/services/cycle_notification_scheduler.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';

/// ISO/IEC/IEEE 29119-1:2022 opisuje splošne koncepte; ne predpisuje predloge.
/// ID: TC-NOTIF-01 | Ime/cilj: razporedi lokalni opomnik pred napovedano menstruacijo.
/// Funkcionalnost: lokalno razporejanje opomnikov na podlagi napovedi. Prioriteta: srednja.
/// Vrsta/tehnika: funkcionalni pozitivni test; preverjanje payload-a in urnika.
/// Predpogoji/okolje: fake notification datasource dovoljuje obvestila; brez OS UI.
/// Podatki: cikel se začne 60 dni po današnjem lokalnem datumu, dolžina 28;
/// napoved: dolžina 28, ovulacija 14. dan, menstruacija 5 dni.
/// Koraki: 1) Pokliči reschedule(enabled=true). Pričakovano vrne true.
/// 2) Izberi prvi period_soon. Pričakovano naslov »Your period may start soon«,
/// datum 26 dni po začetku zadnjega zabeleženega cikla ob 09:00.
/// Končni rezultat: fake urnik vsebuje ta payload/naslov/točen datum in uro.
/// Sledljivost: README lokalne napovedi/opomniki; CycleNotificationScheduler.reschedule.
/// Predpostavka/omejitev: OS lahko obvestilo prikaže drugače; test preveri zahtevo schedulerju.
/// Postpogoji/čiščenje: fake scheduler/shramba se po testu zavržeta.
void main() {
  test('TC-NOTIF-01: razporedi opomnik period_soon ob pričakovanem času', () async {
    final notifications = _FakeNotifications();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).add(const Duration(days: 60));
    final result = await CycleNotificationScheduler(notifications).reschedule(
      cycles: [CycleSummary(id: 'cycle-1', startDate: start, cycleLength: 28, menstruationLength: 5)],
      forecast: const CycleForecast(cycleLength: 28, ovulationDay: 14, menstruationLength: 5),
      enabled: true,
    );
    expect(result, isTrue);
    final reminders = notifications.scheduled.where((item) => item.payload == 'period_soon').toList();
    expect(reminders, hasLength(3));
    final first = reminders.first;
    expect(first.title, 'Your period may start soon');
    expect(first.date, DateTime(start.year, start.month, start.day).add(const Duration(days: 26, hours: 9)));
  });
}

class _FakeNotifications implements NotificationDataSource {
  final scheduled = <({DateTime date, String title, String? payload})>[];
  @override
  Future<void> cancelMany(Iterable<int> ids) async {}
  @override
  Future<bool> notificationsEnabled() async => true;
  @override
  Future<void> showNow({required int id, required String title, required String body, String? payload}) async {}
  @override
  Future<void> schedule({required int id, required DateTime date, required String title, required String body, bool exact = false, String? payload}) async {
    scheduled.add((date: date, title: title, payload: payload));
  }
  @override
  Future<bool> requestPermissions() async => true;
  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
