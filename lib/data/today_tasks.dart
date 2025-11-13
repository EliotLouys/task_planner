import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ADDED
import 'package:zbeub_task_plan/data/tasks.dart';
import 'dart:convert'; // ADDED

class TodayTasksProvider extends ChangeNotifier {
  static const int maxTasks = 10;
  
  final List<Tasks> _tasksForToday = [];
  final _storage = FlutterSecureStorage(); // ADDED Storage instance

  // Dependency on TasksProvider to lookup full task objects
  TasksProvider? _tasksProvider;

  void setTasksProvider(TasksProvider provider) {
    _tasksProvider = provider;
  }

  List<Tasks> get tasksForToday => List.unmodifiable(_tasksForToday);

  int _findIndexById(Tasks task) {
    return _tasksForToday.indexWhere((t) => t.id == task.id);
  }

  void reorderTasks(int oldIndex, int newIndex) {
    // Standard logic for Dart List reorder: if moving down, decrement newIndex by 1
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final task = _tasksForToday.removeAt(oldIndex);
    _tasksForToday.insert(newIndex, task);
    
    _saveTasksForToday();
    notifyListeners();
  }
  
  // ADDED: Save task IDs instead of full task objects
  Future<void> _saveTasksForToday() async {
    final taskIds = _tasksForToday.map((t) => t.id).toList();
    final tasksString = jsonEncode(taskIds); 
    await _storage.write(key: 'today_tasks', value: tasksString); 
  }

  // ADDED: Load task IDs and look up full task objects from main list
  Future<void> loadTasksForToday() async {
    final tasksString = await _storage.read(key: 'today_tasks');
    if (tasksString != null && _tasksProvider != null) {
      final List<dynamic> tasksIdJson = jsonDecode(tasksString) as List<dynamic>;
      _tasksForToday.clear();
      
      // Look up the full Tasks object in the main TasksProvider for each ID
      for (final id in tasksIdJson) {
        final task = _tasksProvider!.getTaskById(id as String);
        if (task != null) {
          _tasksForToday.add(task);
        }
      }
      notifyListeners();
    }
  }

  bool addTaskToToday(Tasks task) {
    if (_tasksForToday.length < maxTasks && _findIndexById(task) == -1) {
      _tasksForToday.add(task);
      _saveTasksForToday(); // Call save on mutation
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeTaskFromToday(Tasks task) {
    final index = _findIndexById(task);
    if (index != -1) {
      _tasksForToday.removeAt(index);
      _saveTasksForToday(); // Call save on mutation
      notifyListeners();
    }
  }

  bool toggleTaskForToday(Tasks task) {
    final index = _findIndexById(task);
    if (index != -1) {
      removeTaskFromToday(task);
      return false;
    } else {
      final success = addTaskToToday(task);
      return success;
    }
  }

  bool isTaskForToday(Tasks task) {
    return _findIndexById(task) != -1;
  }
  
  void updateTask(Tasks oldTask, Tasks newTask) {
    final index = _findIndexById(oldTask);
    if (index != -1) {
      _tasksForToday[index] = newTask;
      _saveTasksForToday(); // Call save on mutation
      notifyListeners();
    }
  }

  void removeDeletedTask(Tasks task) {
    final index = _findIndexById(task);
    if (index != -1) {
      _tasksForToday.removeAt(index);
      _saveTasksForToday(); // Call save on mutation
      notifyListeners();
    }
  }
}