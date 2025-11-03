import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/data/enums.dart';
import 'package:zbeub_task_plan/ui/forms/task_form.dart';

// Helper function to convert the category string from navigation to the enum
TasksCategories _stringToCategory(String title) {
  if (title.contains('pro')) {
    return TasksCategories.professional;
  }
  return TasksCategories.personal;
}

class TaskPage extends StatelessWidget {
  const TaskPage({
    super.key,
    required this.taskCategoryTitle,
    required this.importance,
    required this.urgency,
  });

  final String taskCategoryTitle; // e.g., 'tâches pro' or 'tâches persos'
  final ImportanceLevel importance;        // e.g., 'Important'
  final UrgencyLevel urgency;           // e.g., 'Urgent'

  static Route<void> route(String category, ImportanceLevel importance, UrgencyLevel urgency) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/TaskPage'),
      builder: (_) => TaskPage(
        taskCategoryTitle: category,
        importance: importance,
        urgency: urgency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the category enum from the title passed from the Home Page
    final filterCategory = _stringToCategory(taskCategoryTitle);
    final filterImportance = importance;
    final filterUrgency = urgency;

    return Scaffold(
      appBar: AppBar(
        title: Text('${getImportanceLevelName(importance)} / ${getUrgencyLevelName(urgency)}'),
      ),
      // Consumer listens for changes in TasksProvider and rebuilds the list
      body: Consumer<TasksProvider>(
        builder: (context, tasksProvider, child) {

          final filteredTasks = tasksProvider.tasks.where((task) {
            final categoryMatch = task.category == filterCategory;
            final importanceMatch = task.isImportant == filterImportance;
            final urgencyMatch = task.isUrgent == filterUrgency;

            // Tasks must match all three criteria (Category AND Importance AND Urgency)
            return categoryMatch && importanceMatch && urgencyMatch;
          }).toList();
          // -----------------------

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
              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                    'Échéance: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} à ${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',                  ),
                  trailing: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) {
                      // Toggle completion status
                      tasksProvider.toggleTaskCompletion(task);
                    },
                  ),
                  onTap: () {
                    // debugPrint('Tapped on task: ${task.title}');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showTaskFormModal(
            context,
            initialCategory: filterCategory,
            initialImportanceString: importance,
            initialUrgencyString: urgency,
          );          
          debugPrint('Add new task button pressed');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}