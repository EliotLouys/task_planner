import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/theme/app_theme.dart';
import 'package:zbeub_task_plan/ui/forms/task_form.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/ArchivePage'),
      builder: (_) => const ArchivePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archives des Tâches'),
      ),
      body: Consumer<TasksProvider>(
        builder: (context, tasksProvider, child) {
          final archivedTasks = tasksProvider.archivedTasks;
          
          if (archivedTasks.isEmpty) {
            return const Center(
              child: Text("Aucune tâche archivée."),
            );
          }

          return ListView.builder(
            itemCount: archivedTasks.length,
            itemBuilder: (context, index) {
              final task = archivedTasks[index];
              final categoryColor = AppTheme.getCategoryColor(task.category);

              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                
                // REMOVED: IntrinsicHeight
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures strip covers full height
                  children: [
                    // Category color strip
                    Container(
                      width: 8,
                      height: double.infinity, // Stretches to full height
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppTheme.cardBorderRadius)),
                      ),
                    ),
                    
                    Expanded(
                      child: ListTile(
                        isThreeLine: true, // FIX: Gives more space for the subtitle
                        title: Text(
                          task.title,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.black54,
                          ),
                        ),
                        subtitle: Text(
                          // Long subtitle text
                          'Archivé. Échéance: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} à ${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.black45),
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis, // Ensures text does not break out
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.grey),
                              onPressed: () => tasksProvider.removeTask(task),
                            ),
                            
                            // Unarchive (Toggle Completion) Button
                            IconButton(
                              icon: const Icon(Icons.unarchive, color: Colors.blueGrey),
                              onPressed: () {
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
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}