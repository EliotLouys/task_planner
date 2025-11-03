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

         return ReorderableListView.builder(
            itemCount: tasks.length,
            onReorder: (int oldIndex, int newIndex) {
              todayTasksProvider.reorderTasks(oldIndex, newIndex);
            },
            
            itemBuilder: (context, index) {
              final task = tasks[index];
              final categoryColor = AppTheme.getCategoryColor(task.category);

              return Card(
                key: ValueKey(task.id), 
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: AppTheme.getQuadrantColor(importance: task.isImportant, urgency: task.isUrgent),
                child: IntrinsicHeight(
                  child: Row(
                    
                    crossAxisAlignment: CrossAxisAlignment.stretch, 
                    children: [
                      // Category color strip
                      Container(
                        width: 8, 
                        height: double.infinity, 
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppTheme.cardBorderRadius)),
                        ),
                      ),
                      
                      Expanded(
                        
                        child: ReorderableDragStartListener(
                          index: index, // Pass the current list index
                          child: ListTile(
                            isThreeLine: true, 
                            title: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(
                              'Échéance: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} à ${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis, 
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // ADDED: The visible drag indicator icon
                                const Icon(Icons.drag_indicator, color: Colors.grey),

                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete_forever, color: Colors.grey),
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
                              showTaskFormModal(
                                context,
                                initialCategory: task.category,
                                initialImportanceString: task.isImportant,
                                initialUrgencyString: task.isUrgent,
                                taskToEdit: task,
                              );
                            },
                          ),
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