import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zbeub_task_plan/data/enums.dart';
import 'package:uuid/uuid.dart';
import 'package:zbeub_task_plan/data/today_tasks.dart';
import 'package:zbeub_task_plan/services/notification_service.dart';

final _uuid = const Uuid();

class Tasks {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final TasksCategories category;
  final ImportanceLevel isImportant;
  final UrgencyLevel isUrgent;
  final ReminderValues reminderValue;

  Tasks({
    String? id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.category,
    required this.isImportant,
    required this.isUrgent,
    required this.reminderValue,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include ID in serialization
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'category': category.name,
      'isImportant': isImportant.name,
      'isUrgent': isUrgent.name,
      'reminderValue': reminderValue.name,
    };
  }

  factory Tasks.fromJson(Map<String, dynamic> json) {
    // Helper to parse enum from string name, defaulting to first value if not found
    TasksCategories parseCategory(String name) =>
        TasksCategories.values.firstWhere(
          (e) => e.name == name,
          orElse: () => TasksCategories.personal,
        );
    ImportanceLevel parseImportance(String name) =>
        ImportanceLevel.values.firstWhere(
          (e) => e.name == name,
          orElse: () => ImportanceLevel.notImportant,
        );
    UrgencyLevel parseUrgency(String name) => UrgencyLevel.values.firstWhere(
      (e) => e.name == name,
      orElse: () => UrgencyLevel.notUrgent,
    );
    ReminderValues parseReminder(String? name) =>
        ReminderValues.values.firstWhere(
          (e) => e.name == name,
          // Default to a 30-minute reminder if value is missing from old tasks
          orElse: () => ReminderValues.thirtyMinutesBefore,
        );

    return Tasks(
      id: json['id'] as String,
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'] as bool,
      // Correctly retrieve enum from string name
      category: parseCategory(json['category'] as String),
      isImportant: parseImportance(json['isImportant'] as String),
      isUrgent: parseUrgency(json['isUrgent'] as String),
      reminderValue: parseReminder(json['reminderValue'] as String),
    );
  }

  // Override equality for proper usage in List.indexOf to enable toggleTaskCompletion
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tasks &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          description == other.description &&
          dueDate == other.dueDate &&
          category == other.category &&
          isImportant == other.isImportant &&
          isUrgent == other.isUrgent;

  @override
  int get hashCode =>
      title.hashCode ^
      description.hashCode ^
      dueDate.hashCode ^
      category.hashCode ^
      isImportant.hashCode ^
      isUrgent.hashCode;
}

class TasksProvider extends ChangeNotifier {
  // Dependency injection for TodayTasksProvider, set in main.dart
  TodayTasksProvider? _todayTasksProvider;

  void setTodayTasksProvider(TodayTasksProvider provider) {
    _todayTasksProvider = provider;
  }

  Tasks? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  final List<Tasks> _tasks = [];
  final _storage = FlutterSecureStorage();

  /// Returns an unmodifiable list of all tasks that are NOT completed.
  List<Tasks> get tasks =>
      List.unmodifiable(_tasks.where((t) => !t.isCompleted));

  /// Returns an unmodifiable list of all tasks that ARE completed (the archive).
  List<Tasks> get archivedTasks =>
      List.unmodifiable(_tasks.where((t) => t.isCompleted));

  /// Returns an unmodifiable list of ALL tasks (active and archived).
  List<Tasks> get allTasks => List.unmodifiable(_tasks);

  void addTask(Tasks task) {
    _tasks.add(task);
    NotificationService.scheduleTaskReminder(task);
    saveTasks();
    notifyListeners();
  }

  int getNumberOfTasks(
    ImportanceLevel importance,
    UrgencyLevel urgency,
    TasksCategories category,
  ) {
    return List.unmodifiable(
      _tasks.where(
        (t) =>
            t.isImportant == importance &&
            t.isUrgent == urgency &&
            !t.isCompleted &&
            t.category == category,
      ),
    ).length;
  }

  void removeTask(Tasks task) {
    NotificationService.cancelNotification(task.id);
    _tasks.removeWhere((t) => t.id == task.id); // Remove by ID
    _todayTasksProvider?.removeDeletedTask(task); // Notify today's list
    saveTasks();
    notifyListeners();
  }

  void updateTask(Tasks updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);

    if (index != -1) {
      final oldTask = _tasks[index];
      if (oldTask.dueDate != updatedTask.dueDate ||
          oldTask.title != updatedTask.title ||
          oldTask.isCompleted != updatedTask.isCompleted ||
          oldTask.isImportant != updatedTask.isImportant ||
          oldTask.isUrgent != updatedTask.isUrgent) {
        NotificationService.cancelNotification(oldTask.id);

        // Only schedule if the task is not completed (archived)
        if (!updatedTask.isCompleted) {
          NotificationService.scheduleTaskReminder(updatedTask);
        }
      }

      _tasks[index] = updatedTask;

      // Notify today's list of the change (needed for title/date/etc. edits)
      _todayTasksProvider?.updateTask(oldTask, updatedTask);

      saveTasks();
      notifyListeners();
    }
  }

  void toggleTaskCompletion(Tasks task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);

    if (index != -1) {
      final oldTask = _tasks[index];
      final newTask = Tasks(
        id: oldTask.id,
        title: oldTask.title,
        description: oldTask.description,
        dueDate: oldTask.dueDate,
        isCompleted:
            !oldTask.isCompleted, // Toggle completion (Archive/Unarchive)
        category: oldTask.category,
        isImportant: oldTask.isImportant,
        isUrgent: oldTask.isUrgent,
        reminderValue: oldTask.reminderValue,
      );
      _tasks[index] = newTask;

      // Logic for TodayTasksProvider when archiving/unarchiving
      if (newTask.isCompleted) {
        NotificationService.cancelNotification(newTask.id);
        // If archived, remove it from the list for today
        _todayTasksProvider?.removeDeletedTask(newTask);
      } else {
        NotificationService.scheduleTaskReminder(newTask);
        // If unarchived, update the task instance in the list for today
        _todayTasksProvider?.updateTask(oldTask, newTask);
      }

      saveTasks();
      notifyListeners();
    }
  }

  Future<void> saveTasks() async {
    // Serialize the list of tasks to a proper JSON string
    final tasksJsonList = _tasks.map((t) => t.toJson()).toList();
    final tasksString = jsonEncode(tasksJsonList);
    await _storage.write(key: 'tasks', value: tasksString);
  }

  Future<void> loadTasks() async {
    final tasksString = await _storage.read(key: 'tasks');
    if (tasksString != null) {
      try {
        // Deserialize the JSON string back into a List<Map<String, dynamic>>
        final List<dynamic> tasksJson =
            jsonDecode(tasksString) as List<dynamic>;
        _tasks.clear();

        // Use a loop to handle *individual* task parsing failures (safer)
        final List<Tasks> loadedTasks = [];
        for (final jsonItem in tasksJson) {
          try {
            // This is where individual task parsing happens, allowing corrupt tasks to be skipped.
            loadedTasks.add(Tasks.fromJson(jsonItem as Map<String, dynamic>));
          } catch (e) {
            debugPrint('Skipping corrupt task data: $e');
          }
        }

        _tasks.addAll(loadedTasks);

        // Reschedule notifications only for tasks loaded successfully
        for (final task in loadedTasks.where((t) => !t.isCompleted)) {
          NotificationService.scheduleTaskReminder(task);
        }

        notifyListeners();
      } catch (e) {
        // CRITICAL Failsafe: If the entire JSON decode fails (e.g., bad format from a crash),
        // we print the error and proceed with an empty list instead of crashing.
        debugPrint('FATAL ERROR during batch task JSON decoding on reload: $e');
        _tasks.clear(); // Start clean
      }
    }
  }
}
