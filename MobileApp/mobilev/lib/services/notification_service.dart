// Dart & Flutter imports
import 'dart:io' show Platform;

// Package imports
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

/*
 * MAIN NOTIFICATION SERVICE ---------------------------------------------------
 */

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  // Main plugin initialisation method
  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null);

    tz.initializeTimeZones();
    tz.setLocalLocation(
        tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()));

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}

/*
 * CONSTANTS -------------------------------------------------------------------
 */

// Plugin initialisation
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Platform-specific configuration
const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
  'ID',
  'MobileV',
  'MobileV reminder',
  importance: Importance.max,
  priority: Priority.high,
);

const IOSNotificationDetails iOSPlatformChannelSpecifics =
    IOSNotificationDetails();

final NotificationDetails platformChannelSpecifics = Platform.isAndroid
    ? NotificationDetails(android: androidPlatformChannelSpecifics)
    : NotificationDetails(iOS: iOSPlatformChannelSpecifics);

/*
 * HELPER FUNCTIONS ------------------------------------------------------------
 */

tz.TZDateTime nextInstanceOfTime(int hour) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(Duration(days: 1));
  }
  return scheduledDate;
}

tz.TZDateTime nextInstanceOfDateTime({required int day, required int hour}) {
  tz.TZDateTime scheduledDate = nextInstanceOfTime(hour);
  while (scheduledDate.weekday != day) {
    scheduledDate = scheduledDate.add(Duration(days: 1));
  }
  return scheduledDate;
}
