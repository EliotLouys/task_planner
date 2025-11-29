// lib/ui/all_tasks_page/all_tasks_list_page.dart (was task_page.dart)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/settings.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/data/enums.dart';
import 'package:zbeub_task_plan/data/today_tasks.dart'; // Import new provider
import 'package:zbeub_task_plan/theme/app_theme.dart';
import 'package:zbeub_task_plan/ui/forms/task_form.dart';

// Helper function to convert the category string from navigation to the enum
TasksCategories _stringToCategory(String title) {
  if (title.contains('pro')) {
    return TasksCategories.professional;
  }
  return TasksCategories.personal;
}

class AllTasksPage extends StatelessWidget {
  const AllTasksPage({
    super.key,
    required this.taskCategoryTitle,
    required this.importance,
    required this.urgency,
  });

  final String taskCategoryTitle; // e.g., 'tâches pro' or 'tâches persos'
  final ImportanceLevel importance; // e.g., 'Important'
  final UrgencyLevel urgency; // e.g., 'Urgent'

  static Route<void> route(
    String category,
    ImportanceLevel importance,
    UrgencyLevel urgency,
  ) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/AllTasksListPage'),
      builder:
          (_) => AllTasksPage(
            taskCategoryTitle: category,
            importance: importance,
            urgency: urgency,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterCategory = _stringToCategory(taskCategoryTitle);
    final filterImportance = importance;
    final filterUrgency = urgency;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${getImportanceLevelName(importance)} / ${getUrgencyLevelName(urgency)}',
        ),
      ),
      // Use Multi-Consumer to listen to both tasksProvider and todayTasksProvider
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: context.read<TasksProvider>()),
          ChangeNotifierProvider.value(
            value: context.read<TodayTasksProvider>(),
          ),
          ChangeNotifierProvider.value(value: context.read<SettingsProvider>()),
        ],
        child: Consumer3<TasksProvider, TodayTasksProvider, SettingsProvider>(
          builder: (context, tasksProvider, todayTasksProvider, settingsProvider, child) {
            // Filter the main list of tasks
            final filteredTasks =
                tasksProvider.tasks.where((task) {
                  final categoryMatch = task.category == filterCategory;
                  final importanceMatch = task.isImportant == filterImportance;
                  final urgencyMatch = task.isUrgent == filterUrgency;

                  return categoryMatch && importanceMatch && urgencyMatch;
                }).toList();

            if (filteredTasks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Aucune tâche trouvée pour la catégorie "$taskCategoryTitle" et la matrice "${getImportanceLevelName(importance)} / ${getUrgencyLevelName(urgency)}".',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                final isAddedToToday = todayTasksProvider.isTaskForToday(task);
                final maxTasksLimit = settingsProvider.maxTasksForToday;
                final isTodayListFull = todayTasksProvider.tasksForToday.length >= maxTasksLimit;

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                      'Échéance: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} à ${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: AppTheme.deleteButtonColor,
                          ),
                          onPressed: () => tasksProvider.removeTask(task),
                        ),

                        // Button to add to Today's Tasks
                        IconButton(
                          icon: Icon(
                            isAddedToToday
                                ? Icons.remove_circle
                                : Icons.add_circle,
                            color: isAddedToToday ? Colors.red : Colors.green,
                          ),
                          onPressed:
                              isAddedToToday || !isTodayListFull
                                  ? () {
                                    if (todayTasksProvider.toggleTaskForToday(
                                      task,
                                      maxTasksLimit
                                    )) {
                                      // Task added successfully or removed
                                    } else {
                                      // List is full and task was not removed
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          duration: Duration(seconds: 1),
                                          content: Text(
                                            "La liste pour aujourd'hui est pleine ($maxTasksLimit tâches max).",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  : null, // Disable if list is full and task is not present
                        ),

                        // Checkbox for completion status
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) {
                            tasksProvider.toggleTaskCompletion(task);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      debugPrint('Tapped on task: ${task.title}');
                      showTaskFormModal(
                        context,
                        initialCategory: task.category,
                        initialImportanceString: task.isImportant,
                        initialUrgencyString: task.isUrgent,
                        taskToEdit: task, // Pass the existing task
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showTaskFormModal(
            context,
            initialCategory: filterCategory,
            initialImportanceString: importance,
            initialUrgencyString: urgency,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
