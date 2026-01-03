import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zbeub_task_plan/data/settings.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'dart:convert';

class TodayTasksProvider extends ChangeNotifier {
  final List<Tasks> _tasksForToday = [];
  final _storage = FlutterSecureStorage();

  TasksProvider? _tasksProvider;
  SettingsProvider? _settingsProvider;

  // Stats accumulator for tasks cleared today
  int _archivedCompletedCount = 0;

  void setTasksProvider(TasksProvider provider) {
    _tasksProvider = provider;
  }

  void setSettingsProvider(SettingsProvider provider) {
    _settingsProvider = provider;
  }

  int get maxTasks => _settingsProvider?.maxTasksForToday ?? 5;

  List<Tasks> get tasksForToday => List.unmodifiable(_tasksForToday);

  // --- Stats Getters (Active + Archived) ---
  int get totalTodayCount => _tasksForToday.length + _archivedCompletedCount;

  int get completedTodayCount =>
      _tasksForToday.where((t) => t.isCompleted).length +
      _archivedCompletedCount;

  int _findIndexById(Tasks task) {
    return _tasksForToday.indexWhere((t) => t.id == task.id);
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final task = _tasksForToday.removeAt(oldIndex);
    _tasksForToday.insert(newIndex, task);

    _saveTasksForToday();
    notifyListeners();
  }

  Future<void> _saveTasksForToday() async {
    final taskIds = _tasksForToday.map((t) => t.id).toList();
    final tasksString = jsonEncode(taskIds);
    await _storage.write(key: 'today_tasks', value: tasksString);
  }

  // Save the counter of cleared tasks
  Future<void> _saveArchivedStats() async {
    final data = {
      'date': DateTime.now().toIso8601String(),
      'count': _archivedCompletedCount,
    };
    await _storage.write(key: 'today_stats_archive', value: jsonEncode(data));
  }

  Future<void> loadTasksForToday() async {
    // 1. Load active list
    final tasksString = await _storage.read(key: 'today_tasks');
    if (tasksString != null && _tasksProvider != null) {
      final List<dynamic> tasksIdJson =
          jsonDecode(tasksString) as List<dynamic>;
      _tasksForToday.clear();

      for (final id in tasksIdJson) {
        final task = _tasksProvider!.getTaskById(id as String);
        if (task != null) {
          _tasksForToday.add(task);
        }
      }
    }

    // 2. Load archived stats and ensure they are for "today"
    final statsString = await _storage.read(key: 'today_stats_archive');
    if (statsString != null) {
      try {
        final data = jsonDecode(statsString);
        final savedDate = DateTime.parse(data['date']);
        final now = DateTime.now();

        if (savedDate.year == now.year &&
            savedDate.month == now.month &&
            savedDate.day == now.day) {
          _archivedCompletedCount = data['count'] as int;
        } else {
          _archivedCompletedCount = 0;
          await _storage.delete(key: 'today_stats_archive');
        }
      } catch (e) {
        _archivedCompletedCount = 0;
      }
    }

    notifyListeners();
  }

  // --- UPDATED: Auto-Archive Logic ---
  void updateTask(Tasks oldTask, Tasks newTask) {
    final index = _findIndexById(oldTask);
    if (index != -1) {
      // If the task is now completed, we remove it from the list
      // and increment our stats counter.
      if (newTask.isCompleted && !oldTask.isCompleted) {
        _tasksForToday.removeAt(index);
        _archivedCompletedCount++;
        _saveArchivedStats();
      } else if (!newTask.isCompleted && oldTask.isCompleted) {
        // Edge case: If a task was somehow completed in the list (not archived)
        // and is now uncompleted, we just update it.
        _tasksForToday[index] = newTask;
      } else {
        // Standard update (Title change, etc.)
        _tasksForToday[index] = newTask;
      }

      _saveTasksForToday();
      notifyListeners();
    }
  }

  bool addTaskToToday(Tasks task, int maxLimit) {
    if (_tasksForToday.length < maxLimit && _findIndexById(task) == -1) {
      _tasksForToday.add(task);
      _saveTasksForToday();
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeTaskFromToday(Tasks task) {
    final index = _findIndexById(task);
    if (index != -1) {
      _tasksForToday.removeAt(index);
      _saveTasksForToday();
      notifyListeners();
    }
  }

  bool toggleTaskForToday(Tasks task, int maxLimit) {
    final index = _findIndexById(task);
    if (index != -1) {
      removeTaskFromToday(task);
      return false;
    } else {
      final success = addTaskToToday(task, maxLimit);
      return success;
    }
  }

  bool isTaskForToday(Tasks task) {
    return _findIndexById(task) != -1;
  }

  void removeDeletedTask(Tasks task) {
    final index = _findIndexById(task);
    if (index != -1) {
      _tasksForToday.removeAt(index);
      _saveTasksForToday();
      notifyListeners();
    }
  }
}
