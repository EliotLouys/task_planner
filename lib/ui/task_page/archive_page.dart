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
                
                child: IntrinsicHeight( 
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch, 
                    children: [
                      // Category color strip
                      Container(
                        width: 8,
                        height: double.infinity, // This now safely stretches to the height calculated by IntrinsicHeight
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppTheme.cardBorderRadius)),
                        ),
                      ),
                      
                      Expanded(
                        child: ListTile(
                          title: Text(
                            task.title,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.black54,
                            ),
                          ),
                          subtitle: Text(
                            'Archivé. Échéance: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} à ${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.black45),
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
                              IconButton(
                                icon: const Icon(Icons.unarchive, color: AppTheme.unarchiveButtonColor),
                                onPressed: () {
                                  tasksProvider.toggleTaskCompletion(task);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            // Open form for viewing/editing on tap
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}