import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationDataSourceProvider = Provider<NotificationDataSource>(
  (ref) => NotificationDataSource(FlutterLocalNotificationsPlugin()),
);

class NotificationDataSource {
  NotificationDataSource(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings);
  }
}