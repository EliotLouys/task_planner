import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zbeub_task_plan/services/notification_service.dart';

// --- Keys for Secure Storage ---
const String _kThemeKey = 'settings_theme_mode';
const String _kDailyReminderHourKey = 'settings_daily_reminder_hour';
const String _kDailyReminderMinuteKey = 'settings_daily_reminder_minute';
const String _kMaxTasksKey = 'settings_max_tasks';

// A helper for managing the app's theme based on user preference
enum AppThemeMode { light, dark, system }

class SettingsProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- Internal State (Default Values) ---
  AppThemeMode _currentThemeMode = AppThemeMode.light;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 10, minute: 0);
  int _maxTasksForToday = 5; // Default max tasks

  // --- External Accessors ---
  AppThemeMode get themeMode => _currentThemeMode;
  TimeOfDay get dailyReminderTime => _dailyReminderTime;
  int get maxTasksForToday => _maxTasksForToday;

  // Determines the actual Flutter ThemeMode enum based on the stored preference
  ThemeMode get flutterThemeMode {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // --- Initializer/Loader ---

  // Loads all stored settings on application startup
  Future<void> loadSettings() async {
    // 1. Load Theme Mode (saved as string name)
    final themeString = await _storage.read(key: _kThemeKey);
    if (themeString != null) {
      try {
        _currentThemeMode = AppThemeMode.values.byName(themeString);
      } catch (_) {
        _currentThemeMode = AppThemeMode.light;
      }
    }

    // 2. Load Daily Reminder Time (saved as separate hour and minute strings)
    final hourString = await _storage.read(key: _kDailyReminderHourKey);
    final minuteString = await _storage.read(key: _kDailyReminderMinuteKey);

    if (hourString != null && minuteString != null) {
      try {
        final hour = int.parse(hourString);
        final minute = int.parse(minuteString);
        _dailyReminderTime = TimeOfDay(hour: hour, minute: minute);
      } catch (_) {
        _dailyReminderTime = const TimeOfDay(hour: 10, minute: 0);
      }
    }

    // 3. Load Max Tasks (saved as string)
    final maxTasksString = await _storage.read(key: _kMaxTasksKey);
    if (maxTasksString != null) {
      try {
        _maxTasksForToday = int.parse(maxTasksString);
      } catch (_) {
        _maxTasksForToday = 5;
      }
    }

    notifyListeners();
  }

  // --- Mutators/Updaters ---

  // 1. Theme Mode
  Future<void> toggleThemeMode(bool isDark) async {
    final newMode = isDark ? AppThemeMode.dark : AppThemeMode.light;
    _currentThemeMode = newMode;
    await _storage.write(key: _kThemeKey, value: newMode.name);
    notifyListeners();
  }

  // 2. Daily Reminder Time
  Future<void> setDailyReminderTime(TimeOfDay newTime) async {
    _dailyReminderTime = newTime;

    // Convert TimeOfDay to separate strings for secure storage
    await _storage.write(
      key: _kDailyReminderHourKey,
      value: newTime.hour.toString(),
    );
    await _storage.write(
      key: _kDailyReminderMinuteKey,
      value: newTime.minute.toString(),
    );

    // Reschedule the notification immediately with the new time
    // NOTE: This assumes you will implement a rescheduleDailyReminder(TimeOfDay time)
    // method in your NotificationService.
    NotificationService.rescheduleDailyReminder(newTime);

    notifyListeners();
  }

  // 3. Max Tasks for Today
  Future<void> setMaxTasks(int maxTasks) async {
    // Basic validation
    if (maxTasks < 1 || maxTasks > 20) return;

    _maxTasksForToday = maxTasks;
    await _storage.write(key: _kMaxTasksKey, value: maxTasks.toString());
    notifyListeners();
  }
}

// --- Required Setup for NotificationService (Placeholder) ---

// NOTE: You must add this method to lib/services/notification_service.dart
// to handle the rescheduling logic when the time changes.

// class NotificationService {
//     // ... existing methods
//     static Future<void> rescheduleDailyReminder(TimeOfDay time) async {
//         // 1. Cancel the existing daily reminder
//         // 2. Schedule a new one using the provided TimeOfDay
//         // ... implementation based on your existing logic
//     }
// }
