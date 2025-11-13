
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/data/enums.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  
  // A unique ID for the daily reminder notification
  static const int _dailyReminderId = 0; 
  static const String _channelId = 'task_planner_channel';
  static const String _channelName = 'Task Reminders';
  static const String _channelDescription = 'Notifications for upcoming tasks and daily reviews.';

  // Helper to convert Task ID (String UUID) to a unique int ID for the plugin.
  // We hash the UUID string to get a stable, unique integer ID.
  static int _taskIdToInt(String taskId) {
    // We use the 32-bit hash code to ensure it fits into a stable integer ID.
    return taskId.hashCode.abs();
  }

  /// Initializes timezone data and sets up the notification plugin.
  static Future<void> initialize(DidReceiveNotificationResponseCallback? onDidReceiveBackgroundNotificationResponse) async {
    // Initialize timezone data and set local location (assuming France/Paris timezone based on file names)
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));

    // Android initialization settings
    const androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Setup general settings
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    // Request permissions for Android 13+
    _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
  
  static tz.TZDateTime _nextInstanceOfTenAM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = 
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 10, 0, 0);

    // If it's already past 10 AM, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
  
  /// Schedules a recurring daily notification at 10:00 AM.
  static Future<void> scheduleDailyReminder() async {
    const title = "C'est l'heure !";
    const body = "VAVOIRTéTACH.";
    
    await _notifications.zonedSchedule(
      _dailyReminderId,
      title,
      body,
      _nextInstanceOfTenAM(),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Schedules a reminder 30 minutes before the task is due.
  static Future<void> scheduleTaskReminder(Tasks task) async {
    debugPrint("Scheduling entered");
    // Only schedule if the task is NOT completed
    if (task.isCompleted) return;

    final taskId = _taskIdToInt(task.id);
    final dueDateTime = task.dueDate;
    final scheduledDate = tz.TZDateTime.from(
      dueDateTime.subtract(const Duration(minutes: 30)), 
      tz.local
    );

    // Only schedule if the reminder time is in the future
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      // If task is already due or too close, just cancel any previous reminder
      debugPrint("entered cancelation");
      await cancelNotification(task.id); 
      return; 
    }
    

    // Determine the urgency/importance for the title/body
    final categoryName = getTasksCategoryName(task.category);
    final quadrantName = 
        '${getImportanceLevelName(task.isImportant)} / ${getUrgencyLevelName(task.isUrgent)}';

    final title = "Rappel de tâche : ${task.title}, $categoryName, $quadrantName";
    final body = "La deadline est dans 30 minute";

    debugPrint("just before scheduling");
    await _notifications.zonedSchedule(
      taskId,
      title,
      body,
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint("just after scheduling");
  }

  /// Sends an immediate notification for testing the format.
  static Future<void> showImmediateNotification() async {
    const title = "Notification Test (Ton tableau)";
    const body = "Ceci est un test de notification immédiate. C'est le format que vous recevrez pour vos rappels.";
    
    await _notifications.show(
      // Use a distinct ID for the test notification
      -1, 
      title,
      body,
      _notificationDetails(),
      payload: 'test_payload',
    );
  }

  /// Cancels a specific task reminder using the task's ID.
  static Future<void> cancelNotification(String taskId) async {
    await _notifications.cancel(_taskIdToInt(taskId));
  }
  
  // Utility for getting the notification details (channel config)
  static NotificationDetails _notificationDetails() {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    return const NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
  }
}