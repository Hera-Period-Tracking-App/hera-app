import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

final notificationDataSourceProvider = Provider<NotificationDataSource>(
  (ref) => NotificationDataSource(
    FlutterLocalNotificationsPlugin(),
    ref.watch(secureStorageDataSourceProvider),
  ),
);

class NotificationDataSource {
  NotificationDataSource(this._plugin, this._storage);

  final FlutterLocalNotificationsPlugin _plugin;
  final SecureStorageDataSource _storage;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    timezone_data.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings);
    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();

    // Remember that the app has requested permission, but do not use this to
    // block future manual requests from the Settings toggle.
    await _storage.write(
      AppConstants.notificationPermissionPromptedKey,
      'true',
    );

    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final iOSGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return androidGranted ?? iOSGranted ?? await notificationsEnabled();
  }

  Future<bool> notificationsEnabled() async {
    await initialize();

    final androidNotifications = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final androidEnabled = await androidNotifications?.areNotificationsEnabled();
    if (androidEnabled != null) {
      return androidEnabled;
    }

    final iOSNotifications = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final iOSEnabled = await iOSNotifications?.checkPermissions();
    return iOSEnabled?.isEnabled ?? true;
  }

  Future<bool> requestExactAlarmPermission() async {
    await initialize();

    final androidNotifications = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidNotifications == null) {
      return true;
    }

    final canScheduleExact =
        await androidNotifications.canScheduleExactNotifications();
    if (canScheduleExact ?? true) {
      return true;
    }

    return await androidNotifications.requestExactAlarmsPermission() ?? false;
  }

  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id);
  }

  Future<void> cancelMany(Iterable<int> ids) async {
    await initialize();
    for (final id in ids) {
      await _plugin.cancel(id);
    }
  }

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cycle_predictions',
          'Cycle predictions',
          channelDescription:
              'Reminders for predicted menstruation, ovulation, and cycle phases.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> schedule({
    required int id,
    required DateTime date,
    required String title,
    required String body,
    bool exact = false,
    String? payload,
  }) async {
    await initialize();

    final scheduledDate = timezone.TZDateTime.from(date, timezone.local);
    if (!scheduledDate.isAfter(timezone.TZDateTime.now(timezone.local))) {
      return;
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cycle_predictions',
          'Cycle predictions',
          channelDescription:
              'Reminders for predicted menstruation, ovulation, and cycle phases.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    await initialize();
    return _plugin.pendingNotificationRequests();
  }
}
