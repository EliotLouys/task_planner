import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/settings.dart';
import 'package:zbeub_task_plan/data/today_tasks.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/theme/app_theme.dart';
import 'package:zbeub_task_plan/ui/forms/task_form.dart';

// 1. Convert to StatefulWidget to handle the "Animation Delay" state
class TodayTasksPage extends StatefulWidget {
  const TodayTasksPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/TodayTasksPage'),
      builder: (_) => const TodayTasksPage(),
    );
  }

  @override
  State<TodayTasksPage> createState() => _TodayTasksPageState();
}

class _TodayTasksPageState extends State<TodayTasksPage> {
  // 2. We keep track of tasks that are currently "animating out"
  final Set<String> _animatingTaskIds = {};

  // Helper function to handle the delay
  Future<void> _handleTaskActionWithDelay({
    required String taskId,
    required Future<void> Function() onAction,
  }) async {
    // A. Mark as animating (triggers the visual shrink)
    setState(() {
      _animatingTaskIds.add(taskId);
    });

    // B. Wait for your animation duration (1500ms as per your code)
    await Future.delayed(const Duration(milliseconds: 1500));

    // Check if user left the screen
    if (!mounted) return;

    // C. ACTUAL Data Update (Provider)
    await onAction();

    // D. Cleanup (though the item is likely gone from the list now)
    if (mounted) {
      setState(() {
        _animatingTaskIds.remove(taskId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tâches pour Aujourd'hui")),
      body: Consumer2<TodayTasksProvider, TasksProvider>(
        builder: (context, todayTasksProvider, tasksProvider, child) {
          final tasks = todayTasksProvider.tasksForToday;

          // 3. LOGIC FIX:
          // We only show the Empty Message if the list is empty AND nothing is currently animating.
          // This keeps the ListView alive while the last item shrinks.
          final activeTasksCount =
              tasks.where((element) => !element.isCompleted).length;
          final isTrulyEmpty =
              activeTasksCount == 0 && _animatingTaskIds.isEmpty;

          if (isTrulyEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
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

              // 4. CHECK BOTH: Is it completed in data? OR is it currently animating out?
              final bool isAnimating = _animatingTaskIds.contains(task.id);
              final bool isCompleted = task.isCompleted || isAnimating;

              const double cardHeight = 100.0;
              final double targetHeight = isCompleted ? 0.0 : cardHeight + 12.0;
              final double targetMarginVertical = isCompleted ? 0.0 : 6.0;

              return AnimatedContainer(
                key: ValueKey(task.id),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOutCubic,
                height: targetHeight,
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: targetMarginVertical,
                ),
                child: ClipRect(
                  child: AnimatedOpacity(
                    opacity: isCompleted ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOut,
                    child: Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      color: AppTheme.getQuadrantColor(
                        importance: task.isImportant,
                        urgency: task.isUrgent,
                      ),
                      child: SizedBox(
                        height: cardHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                          isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                    ),
                                  ),
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
                                      // DELETE BUTTON
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
                                        onPressed: () {
                                          // Trigger delay before deleting
                                          _handleTaskActionWithDelay(
                                            taskId: task.id,
                                            onAction:
                                                () async => tasksProvider
                                                    .removeTask(task),
                                          );
                                        },
                                      ),
                                      // REMOVE FROM TODAY BUTTON
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
                                          // Trigger delay before removing
                                          _handleTaskActionWithDelay(
                                            taskId: task.id,
                                            onAction:
                                                () async => todayTasksProvider
                                                    .removeTaskFromToday(task),
                                          );
                                        },
                                      ),
                                      // CHECKBOX
                                      Transform.scale(
                                        scale: 0.8,
                                        child: Checkbox(
                                          value:
                                              isCompleted, // Use our combined bool
                                          onChanged: (_) {
                                            // Trigger delay before toggling completion
                                            _handleTaskActionWithDelay(
                                              taskId: task.id,
                                              onAction:
                                                  () async => tasksProvider
                                                      .toggleTaskCompletion(
                                                        task,
                                                      ),
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
                                    if (!isCompleted) {
                                      showTaskFormModal(
                                        context,
                                        initialCategory: task.category,
                                        initialImportanceString:
                                            task.isImportant,
                                        initialUrgencyString: task.isUrgent,
                                        taskToEdit: task,
                                      );
                                    }
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
