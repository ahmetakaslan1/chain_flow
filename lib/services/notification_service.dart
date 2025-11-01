import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _configureLocalTimeZone();
    await _initializePlugin();
    await _requestPermissions();
  }

  Future<void> _initializePlugin() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<void> _requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Handle notification when app is in foreground
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    // Handle notification tap
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
  }

  Future<void> showNotification(int id, String title, String body, String payload) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'chainflow_channel', 'ChainFlow Notifications',
      channelDescription: 'Notifications for ChainFlow Local App',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
        id, title, body, platformChannelSpecifics, payload: payload);
  }

  Future<void> scheduleDailyNotification(int id, String title, String body, TimeOfDay notificationTime) async {
    await cancelNotification(id);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(notificationTime),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'chainflow_channel', 'ChainFlow Daily Reminders',
          channelDescription: 'Daily reminder to break the chain',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleSavedDailyReminder() async {
    final settingsBox = Hive.box('settings');
    final int? hour = settingsBox.get('notificationHour');
    final int? minute = settingsBox.get('notificationMinute');
    if (hour == null || minute == null) return;
    final language = settingsBox.get('appLocale', defaultValue: 'tr') as String;
    final title = language == 'en' ? 'ChainFlow Reminder' : 'ChainFlow Hatırlatıcısı';
    final body = language == 'en'
        ? "Don't forget to mark your progress today!"
        : 'Bugünkü ilerlemeni işaretlemeyi unutma!';
    await scheduleDailyNotification(
      0,
      title,
      body,
      TimeOfDay(hour: hour, minute: minute),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay notificationTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, notificationTime.hour, notificationTime.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
