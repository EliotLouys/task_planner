import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/settings.dart';
import 'package:zbeub_task_plan/data/today_tasks.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/theme/app_theme.dart';
import 'package:zbeub_task_plan/ui/forms/task_form.dart';

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
  final Set<String> _animatingTaskIds = {};

  Future<void> _handleTaskActionWithDelay({
    required String taskId,
    required Future<void> Function() onAction,
  }) async {
    // 1. Start Visual Animation
    if (mounted) {
      setState(() {
        _animatingTaskIds.add(taskId);
      });
    }

    // 2. Wait for animation to play (shrink/fade)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. Update Data
    // This will trigger TodayTasksProvider.updateTask(), removing the task.
    await onAction();

    // 4. Cleanup
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

          // Check if list is effectively empty (considering animations)
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

              // Determine if task is completed or currently animating out
              final bool isAnimating = _animatingTaskIds.contains(task.id);
              // Note: task.isCompleted will likely be false here until the animation
              // finishes and it gets removed, but we check both just in case.
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
                                    'Échéance: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // REMOVE FROM TODAY BUTTON (Still useful if you just want to remove without completing)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                        iconSize: 20.0,
                                        onPressed: () {
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
                                          value: isCompleted,
                                          onChanged: (_) {
                                            // This starts the animation, then calls toggle.
                                            // Toggle calls updateTask, which now removes the task.
                                            _handleTaskActionWithDelay(
                                              taskId: task.id,
                                              onAction:
                                                  () async => tasksProvider
                                                      .toggleTaskCompletion(
                                                        task,
                                                      ),
                                            );
                                          },
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
