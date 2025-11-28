import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/theme/app_theme.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Define dynamic colors for the archived (low-emphasis) state
    final taskTitleColor = isDarkMode ? Colors.white54 : Colors.black54;
    final taskSubtitleColor = isDarkMode ? Colors.white38 : Colors.black45;

    return Scaffold(
      appBar: AppBar(title: const Text('Archives des Tâches')),
      body: Consumer<TasksProvider>(
        builder: (context, tasksProvider, child) {
          final archivedTasks = tasksProvider.archivedTasks;

          if (archivedTasks.isEmpty) {
            return const Center(child: Text("Aucune tâche archivée."));
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
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(AppTheme.cardBorderRadius),
                          ),
                        ),
                      ),

                      Expanded(
                        child: ListTile(
                          // REMOVED: isThreeLine: true
                          // FIX: Use the 'content' slot to wrap text elements in Expanded
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title - Enforce 1 line limit with ellipsis
                              Text(
                                task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: taskTitleColor,
                                ),
                              ),
                              // Subtitle - Enforce 2 line limit with ellipsis
                              Text(
                                'Archivé. Échéance: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: taskSubtitleColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          // Place the icon Row directly in trailing
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Delete Button
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.grey,
                                ),
                                onPressed: () => tasksProvider.removeTask(task),
                              ),

                              // Unarchive (Toggle Completion) Button
                              IconButton(
                                icon: const Icon(
                                  Icons.unarchive,
                                  color: Colors.blueGrey,
                                ),
                                onPressed: () {
                                  tasksProvider.toggleTaskCompletion(task);
                                },
                              ),
                            ],
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
