import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zbeub_task_plan/data/enums.dart';
import 'package:zbeub_task_plan/services/notification_service.dart';

// --- Keys for Secure Storage ---
const String _kThemeKey = 'settings_theme_mode';
const String _kDailyReminderHourKey = 'settings_daily_reminder_hour';
const String _kDailyReminderMinuteKey = 'settings_daily_reminder_minute';
const String _kMaxTasksKey = 'settings_max_tasks';

// A helper for managing the app's theme based on user preference

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

  Future<void> loadSettings() async {
    try {
      // 1. Load Theme Mode (saved as string name)
      final themeString = await _storage.read(key: _kThemeKey);
      if (themeString != null) {
        _currentThemeMode = AppThemeMode.values.byName(themeString);
      }

      // 2. Load Daily Reminder Time
      final hourString = await _storage.read(key: _kDailyReminderHourKey);
      final minuteString = await _storage.read(key: _kDailyReminderMinuteKey);

      // Safely parse integers, providing defaults if null or invalid
      final hour = int.tryParse(hourString ?? '') ?? 10;
      final minute = int.tryParse(minuteString ?? '') ?? 0;
      _dailyReminderTime = TimeOfDay(hour: hour, minute: minute);

      // 3. Load Max Tasks
      final maxTasksString = await _storage.read(key: _kMaxTasksKey);
      _maxTasksForToday = int.tryParse(maxTasksString ?? '') ?? 5;

      // Ensure the loaded value is within limits (1-10)
      if (_maxTasksForToday < 1 || _maxTasksForToday > 10) {
        _maxTasksForToday = 5;
      }
    } catch (e) {
      // CRITICAL Failsafe: If any SecureStorage operation fails on reload, we ensure defaults are kept
      debugPrint('FATAL ERROR during settings loading on reload: $e');
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
