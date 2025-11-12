import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _generateUniqueId(String input) {
    return input.hashCode.toUnsigned(31);
  }

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris')); 
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: iosSettings,
    );

    // 1. Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    // 2. Request permission at runtime (required for Android 13+)
    // This will pop up the native system dialog asking the user for authorization
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation = 
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
    // Optionally request precise alarm scheduling permission if needed
    // bool? preciseAlarmGranted = await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.requestExactAlarmsPermission();

  }

  Future<void> showInstantNotification(int id, String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'instant_channel', 
      'Notification Test',
      channelDescription: 'Canal de test instantané.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'test_ticker',
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: 'instant_test',
    );
  }

  Future<void> scheduleTaskDeadlineNotification(
      String taskId, DateTime deadline, String title, String body) async {
    
    print("AAAAAAAAAAAAAAAAZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ");

    // 1. Calculate the scheduled time (5 minutes before the deadline)
    final scheduleTime = deadline.subtract(const Duration(minutes: 1));

    // Convert to a TZDateTime object
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduleTime, tz.local);
    print(scheduledDate);
    // Only schedule if the notification time is in the future
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      print('Hello');
      // If the deadline is less than 5 minutes away (or in the past), skip scheduling.
      // This prevents unnecessary immediate notification attempts on old tasks.
      return; 
    }

    final id = _generateUniqueId(taskId);
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'deadline_channel', // New channel ID for deadlines
      'Rappel d\'échéance',
      channelDescription: 'Rappel 5 minutes avant la date limite d\'une tâche.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Existing function (kept for daily reminder)
  Future<void> scheduleDailyNotification(
      int id, String title, String body, TimeOfDay time) async {
    
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_task_channel', 
      'Rappel Quotidien',   
      channelDescription: 'Rappel pour vérifier les tâches du jour.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

final NotificationService notificationService = NotificationService();