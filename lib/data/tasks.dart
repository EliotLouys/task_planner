
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zbeub_task_plan/data/enums.dart';

class Tasks {
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final TasksCategories category;
  final ImportanceLevel isImportant; 
  final UrgencyLevel isUrgent; 

  Tasks({
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.category,
    required this.isImportant,
    required this.isUrgent,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'category': category,
      'isImportant': isImportant,
      'isUrgent': isUrgent,
    };
  }

  factory Tasks.fromJson(Map<String, dynamic> json) {
    return Tasks(
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
      category: json['category'],
      isImportant: json['isImportant'],
      isUrgent: json['isUrgent'],
    );
  }

}

class TasksProvider extends ChangeNotifier{
  final List<Tasks> _tasks = [];
  final _storage = FlutterSecureStorage();

  List<Tasks> get tasks => List.unmodifiable(_tasks);

  void addTask(Tasks task) {
    _tasks.add(task);
    notifyListeners();
  }

  void removeTask(Tasks task) {
    _tasks.remove(task);
    notifyListeners();
  }

  void toggleTaskCompletion(Tasks task) {
    final index = _tasks.indexOf(task);
    if (index != -1) {
      _tasks[index] = Tasks(
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        isCompleted: !task.isCompleted,
        category: task.category,
        isImportant: task.isImportant,
        isUrgent: task.isUrgent,
      );
      notifyListeners();
    }
  }

  Future<void> saveTasks() async {
    await _storage.write(key: 'tasks', value: _tasks.map((t) => t.toJson()).toList().toString()); 
  }

  Future<void> loadTasks() async {
    final tasksString = await _storage.read(key: 'tasks');
    if (tasksString != null) {
      final List<dynamic> tasksJson = tasksString as List<dynamic>;
      _tasks.clear();
      _tasks.addAll(tasksJson.map((json) => Tasks.fromJson(json)).toList());
      notifyListeners();
    }
  }

}