import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/settings.dart';
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
      appBar: AppBar(title: const Text("Tâches pour Aujourd'hui")),
      body: Consumer2<TodayTasksProvider, TasksProvider>(
        builder: (context, todayTasksProvider, tasksProvider, child) {
          final tasks = todayTasksProvider.tasksForToday;

          if (tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                // 2. Use Selector to explicitly watch the maxTasksForToday value from SettingsProvider.
                // This ensures an immediate rebuild of the Text widget whenever the setting is changed.
                child: Selector<SettingsProvider, int>(
                  selector: (_, settings) => settings.maxTasksForToday,
                  builder: (ctx, maxTasks, __) {
                    return Text(
                      "Ajoutez jusqu'à $maxTasks tâches depuis les matrices pour aujourd'hui!",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                  },
                ),
              ),
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
              // --- ANIMATION LOGIC START ---
              final bool isCompleted = task.isCompleted;
              // Fixed height for a 3-line ListTile + padding/margins
              const double cardHeight = 100.0;
              // 6.0 vertical margin on Card in original implementation.
              // We use 100.0 + 2*6.0 = 112.0 as the target open height.
              final double targetHeight = isCompleted ? 0.0 : cardHeight + 12.0;
              final double targetMarginVertical = isCompleted ? 0.0 : 6.0;

              return AnimatedContainer(
                key: ValueKey(
                  task.id,
                ), // Key MUST be here for ReorderableListView
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOutCubic,
                height: targetHeight,
                // Use padding to simulate margin collapse
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: targetMarginVertical,
                ),

                child: ClipRect(
                  // Clips the content as it shrinks/expands
                  child: AnimatedOpacity(
                    opacity: isCompleted ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOut,
                    // 3. The actual Card content (must contain the drag listener)
                    child: Card(
                      elevation: 1,
                      // Margin is controlled by the AnimatedContainer padding above
                      margin: EdgeInsets.zero,
                      color: AppTheme.getQuadrantColor(
                        importance: task.isImportant,
                        urgency: task.isUrgent,
                      ),
                      // Enforce a minimum height for predictable animation
                      child: SizedBox(
                        height: cardHeight,
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
                                  left: Radius.circular(
                                    AppTheme.cardBorderRadius,
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              // 4. RESTORED: ReorderableDelayedDragStartListener (for long-press drag)
                              child: ReorderableDelayedDragStartListener(
                                index: index,
                                child: ListTile(
                                  isThreeLine: true,
                                  title: Text(
                                    task.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      decoration:
                                          task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                    ),
                                  ),
                                  // ... (rest of subtitle and trailing content is here)
                                  subtitle: Text(
                                    'Échéance: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} à ${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // 2. Delete Button
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_forever,
                                          color: Colors.grey,
                                        ),
                                        iconSize: 20.0,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 22,
                                          minHeight: 28,
                                        ),
                                        onPressed:
                                            () =>
                                                tasksProvider.removeTask(task),
                                      ),

                                      // 3. Remove from Today's List button
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                        iconSize: 20.0,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 22,
                                          minHeight: 28,
                                        ),
                                        onPressed: () {
                                          todayTasksProvider
                                              .removeTaskFromToday(task);
                                        },
                                      ),

                                      // 4. Checkbox
                                      Transform.scale(
                                        scale: 0.8,
                                        child: Checkbox(
                                          value: task.isCompleted,
                                          onChanged: (_) {
                                            tasksProvider.toggleTaskCompletion(
                                              task,
                                            );
                                          },
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
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
                    ),
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
