// This code is based on: https://www.freecodecamp.org/news/local-notifications-in-flutter/

// Dart & Flutter imports
import 'dart:io' show Platform;

// Package imports
import 'package:flutter/material.dart';
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

  // Plugin initialisation method (called in main.dart on the instance created below)
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

// Cancel all scheduled notifications
Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

// Weekly (recurring) notification scheduler
Future<void> scheduleNotification(int daySet, TimeOfDay timeSet) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    1,
    'Weekly reminder',
    'Please remember to make a recording',
    nextInstanceOfDateTime(
      day: daySet,
      hour: timeSet.hour,
      minute: timeSet.minute,
    ),
    platformChannelSpecifics,
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

// Plugin instance creation
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

// These two functions are used to return the correct TZDateTime object for the notification to be scheduled

tz.TZDateTime nextInstanceOfTime(int hour, int minute) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(Duration(days: 1));
  }
  return scheduledDate;
}

tz.TZDateTime nextInstanceOfDateTime(
    {required int day, required int hour, required int minute}) {
  tz.TZDateTime scheduledDate = nextInstanceOfTime(hour, minute);
  while (scheduledDate.weekday != day) {
    scheduledDate = scheduledDate.add(Duration(days: 1));
  }
  return scheduledDate;
}
