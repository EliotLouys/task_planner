import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/today_tasks.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/theme/app_theme.dart';
import 'package:zbeub_task_plan/ui/forms/task_form.dart';

class TodayTasksPage extends StatelessWidget {
  const TodayTasksPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/TodayTasksPage'),
      builder: (_) => const TodayTasksPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tâches pour Aujourd'hui"),
      ),
      body: Consumer2<TodayTasksProvider, TasksProvider>(
        builder: (context, todayTasksProvider, tasksProvider, child) {
          final tasks = todayTasksProvider.tasksForToday;
          
          if (tasks.isEmpty) {
            return const Center(
              child: Text("Ajoutez jusqu'à 5 tâches depuis les matrices pour aujourd'hui!"),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              
              // Only retrieving category color, as the quadrant color is no longer used for the tint
              final categoryColor = AppTheme.getCategoryColor(task.category);

              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                // REMOVED: color: quadrantColor.withOpacity(0.1)
                color: AppTheme.getQuadrantColor(importance: task.isImportant, urgency: task.isUrgent),
                child: IntrinsicHeight(
                  child:
                  Row( // Use Row to place the color bar next to the content
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Thin vertical rectangle for category color (The strip)
                      Container(
                        width: 8, // Thin width
                        height: double.infinity , 
                        decoration: BoxDecoration(
                          color: categoryColor, // This is the category color (Personal/Professional)
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppTheme.cardBorderRadius)),
                        ),
                      ),
                      
                      // 2. Task Content (Expanded to fill remaining space)
                      Expanded(
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
                            'Échéance: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} à ${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_forever, color: AppTheme.deleteButtonColor),
                                onPressed: () => tasksProvider.removeTask(task),
                              ),
                              // Remove from Today's List button
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  todayTasksProvider.removeTaskFromToday(task);
                                },
                              ),
                              // Checkbox for completion status (updates main task list)
                              Checkbox(
                                value: task.isCompleted,
                                onChanged: (_) {
                                  tasksProvider.toggleTaskCompletion(task);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            debugPrint('Tapped on task for today: ${task.title}');
                            showTaskFormModal(
                              context,
                              initialCategory: task.category,
                              initialImportanceString: task.isImportant,
                              initialUrgencyString: task.isUrgent,
                              taskToEdit: task, // Pass the existing task
                            );
                          },
                      ),
                    ),
                  ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}