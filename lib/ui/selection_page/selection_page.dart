// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/enums.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/ui/task_page/all_task_page.dart';
import 'package:zbeub_task_plan/theme/app_theme.dart';

TasksCategories _stringToCategory(String title) {
  if (title.contains('pro')) {
    return TasksCategories.professional;
  }
  return TasksCategories.personal;
}

class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key, required this.title});

  final String title;

  static Route<void> route(String title) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/SelectionPage'),
      builder: (_) => SelectionPage(title: title),
    );
  }

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  Widget _buildClickableCard({
    required TasksProvider tasksProvider,
    required ImportanceLevel importance,
    required UrgencyLevel urgency,
    required TasksCategories category,
  }) {
    final importanceName = getImportanceLevelName(importance);
    final urgencyName = getUrgencyLevelName(urgency);
    final quadrantColor = AppTheme.getQuadrantColor(
      importance: importance,
      urgency: urgency,
    );

    // CALCUL : Filtrer les tâches actives (non archivées/non complétées)
    final taskCount =
        tasksProvider.tasks.where((task) {
          return task.category == category &&
              task.isImportant == importance &&
              task.isUrgent == urgency;
        }).length;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8.0),
      color: quadrantColor,
      child: InkWell(
        // Navigation vers la page de la matrice
        onTap: () {
          Navigator.push(
            context,
            AllTasksPage.route(
              // Utilise la route mise à jour pour la liste des tâches
              widget.title,
              importance,
              urgency,
            ),
          );
        },
        splashColor: Colors.white70,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Changé à spaceBetween pour placer le compteur en bas
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Texte 1 (Titre: Importance)
              Text(
                urgencyName == "Urgent" ? urgencyName : importanceName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              // Texte 2 (Sous-titre: Urgence)
              Text(
                urgencyName == "Urgent" ? importanceName : urgencyName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),

              Text(
                'Tâches restantes: $taskCount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = _stringToCategory(widget.title);

    return Scaffold(
      appBar: AppBar(title: Text('Classes des ${widget.title}')),
      // GridView fills the remaining screen space
      body: Consumer<TasksProvider>(
        builder: (context, tasksProvider, child) {
          return GridView.count(
            // Creates a 2x2 grid (2 columns)
            crossAxisCount: 2,
            // The children will be equally sized to fill the space
            children: <Widget>[
              // --- Card 1: Important / Urgent ---
              _buildClickableCard(
                tasksProvider: tasksProvider,
                category: currentCategory,
                importance: ImportanceLevel.important,
                urgency: UrgencyLevel.urgent,
              ),

              // --- Card 2: Pas important / Urgent ---
              _buildClickableCard(
                tasksProvider: tasksProvider,
                category: currentCategory,
                importance: ImportanceLevel.notImportant,
                urgency: UrgencyLevel.urgent,
              ),

              // --- Card 3: Important / Pas urgent ---
              _buildClickableCard(
                tasksProvider: tasksProvider,
                category: currentCategory,
                importance: ImportanceLevel.important,
                urgency: UrgencyLevel.notUrgent,
              ),

              // --- Card 4: Pas important / Pas urgent ---
              _buildClickableCard(
                tasksProvider: tasksProvider,
                category: currentCategory,
                importance: ImportanceLevel.notImportant,
                urgency: UrgencyLevel.notUrgent,
              ),
            ],
          );
        },
      ),
    );
  }
}
