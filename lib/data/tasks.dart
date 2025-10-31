
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zbeub_task_plan/data/enums.dart';
import 'package:uuid/uuid.dart';
import 'package:zbeub_task_plan/data/today_tasks.dart';

final _uuid =const Uuid();

class Tasks {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final TasksCategories category;
  final ImportanceLevel isImportant; 
  final UrgencyLevel isUrgent; 

  Tasks({
    String? id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.category,
    required this.isImportant,
    required this.isUrgent,
  }): id = id ?? _uuid.v4();

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
    };
  }

  factory Tasks.fromJson(Map<String, dynamic> json) {
    // Helper to parse enum from string name, defaulting to first value if not found
    TasksCategories parseCategory(String name) => TasksCategories.values.firstWhere(
        (e) => e.name == name,
        orElse: () => TasksCategories.personal);
    ImportanceLevel parseImportance(String name) => ImportanceLevel.values.firstWhere(
        (e) => e.name == name,
        orElse: () => ImportanceLevel.notImportant);
    UrgencyLevel parseUrgency(String name) => UrgencyLevel.values.firstWhere(
        (e) => e.name == name,
        orElse: () => UrgencyLevel.notUrgent);
        
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
  int get hashCode => title.hashCode ^ description.hashCode ^ dueDate.hashCode ^ category.hashCode ^ isImportant.hashCode ^ isUrgent.hashCode;


}


class TasksProvider extends ChangeNotifier{
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

  List<Tasks> get tasks => List.unmodifiable(_tasks);

  void addTask(Tasks task) {
    _tasks.add(task);
    saveTasks();
    notifyListeners();
  }

  void removeTask(Tasks task) {
    _tasks.removeWhere((t) => t.id == task.id); // Remove by ID
    _todayTasksProvider?.removeDeletedTask(task); // Notify today's list
    saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(Tasks task) {
    final index = _tasks.indexWhere((t) => t.id == task.id); // Find by ID
    print(index);

    if (index != -1) {
      final oldTask = _tasks[index];
      final newTask = Tasks(
        id: oldTask.id, // Preserve ID
        title: oldTask.title,
        description: oldTask.description,
        dueDate: oldTask.dueDate,
        isCompleted: !oldTask.isCompleted, // Toggle
        category: oldTask.category,
        isImportant: oldTask.isImportant,
        isUrgent: oldTask.isUrgent,
      );
      _tasks[index] = newTask; // Replace old instance with new one

      // Notify today's list of the change in state (isCompleted)
      _todayTasksProvider?.updateTask(oldTask, newTask);

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
      // Deserialize the JSON string back into a List<Map<String, dynamic>>
      final List<dynamic> tasksJson = jsonDecode(tasksString) as List<dynamic>;
      _tasks.clear();
      // Map the list of dynamic objects (maps) to Task objects
      _tasks.addAll(tasksJson.map((json) => Tasks.fromJson(json as Map<String, dynamic>)).toList());
      notifyListeners();
    }
  }

}