import 'package:flutter/material.dart';
import 'package:zbeub_task_plan/data/tasks.dart';

class TodayTasksProvider extends ChangeNotifier {
  // Max number of tasks allowed for today
  static const int maxTasks = 5;
  
  // Changed to List to explicitly maintain order.
  final List<Tasks> _tasksForToday = [];

  // Returns the internal list directly (it's already guarded by List.unmodifiable in the previous step)
  List<Tasks> get tasksForToday => List.unmodifiable(_tasksForToday);

  // Helper to find the index of a task by its ID
  int _findIndexById(Tasks task) {
    // We use indexWhere with the task's ID for reliable lookup in the List.
    return _tasksForToday.indexWhere((t) => t.id == task.id);
  }

  // Attempts to add a task. Returns true if added, false if list is full or task is already present.
  bool addTaskToToday(Tasks task) {
    if (_tasksForToday.length < maxTasks && _findIndexById(task) == -1) {
      _tasksForToday.add(task);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Removes a task from the list for today.
  void removeTaskFromToday(Tasks task) {
    final index = _findIndexById(task);
    if (index != -1) {
      _tasksForToday.removeAt(index);
      notifyListeners();
    }
  }

  // Toggles the presence of the task in the list, respecting the max limit.
  bool toggleTaskForToday(Tasks task) {
    final index = _findIndexById(task);
    if (index != -1) {
      removeTaskFromToday(task);
      return false; // Task was removed
    } else {
      return addTaskToToday(task);
      // Returns true if added successfully, false if the list was full
    }
  }

  // Utility to check if a task is already on the list for today
  bool isTaskForToday(Tasks task) {
    return _findIndexById(task) != -1;
  }
  
  // MODIFIED: Replaces the task at its exact index to preserve list order.
  void updateTask(Tasks oldTask, Tasks newTask) {
    final index = _findIndexById(oldTask);
    if (index != -1) {
      // Replace the old task instance with the new one at the same position.
      _tasksForToday[index] = newTask;
      notifyListeners();
    }
  }

  // Removes a deleted task (by ID check)
  void removeDeletedTask(Tasks task) {
    final index = _findIndexById(task);
    if (index != -1) {
      _tasksForToday.removeAt(index);
      notifyListeners();
    }
  }
}
