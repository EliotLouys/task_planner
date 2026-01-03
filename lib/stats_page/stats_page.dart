// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/data/enums.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/data/today_tasks.dart'; // Import TodayTasksProvider
import 'package:zbeub_task_plan/theme/app_theme.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/StatsPage'),
      builder: (_) => const StatsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques Avancées')),
      // 1. Listen to both Providers
      body: Consumer2<TasksProvider, TodayTasksProvider>(
        builder: (context, tasksProvider, todayTasksProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // --- SECTION 1: TODAY'S STATS ---
                Text(
                  "Aujourd'hui",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                _buildTodaySummary(context, todayTasksProvider),

                const SizedBox(height: 32),

                // --- SECTION 2: GLOBAL STATS (Pie Chart) ---
                Text(
                  "Répartition Globale",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200, // Reduced height
                  child: _buildPieChart(context, tasksProvider),
                ),
                // Legend
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  children: [
                    _buildLegendItem(
                      context,
                      tasksProvider,
                      ImportanceLevel.important,
                      UrgencyLevel.urgent,
                    ),
                    _buildLegendItem(
                      context,
                      tasksProvider,
                      ImportanceLevel.important,
                      UrgencyLevel.notUrgent,
                    ),
                    _buildLegendItem(
                      context,
                      tasksProvider,
                      ImportanceLevel.notImportant,
                      UrgencyLevel.urgent,
                    ),
                    _buildLegendItem(
                      context,
                      tasksProvider,
                      ImportanceLevel.notImportant,
                      UrgencyLevel.notUrgent,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- SECTION 3: CATEGORY STATS ("Something like that") ---
                Text(
                  "Performance par Catégorie",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                _buildCategoryComparison(context, tasksProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTodaySummary(
    BuildContext context,
    TodayTasksProvider todayProvider,
  ) {
    final total = todayProvider.totalTodayCount;
    final completed = todayProvider.completedTodayCount;

    if (total == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "Aucune tâche prévue pour aujourd'hui.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final progress = total == 0 ? 0.0 : completed / total;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Circular Progress Indicator
            SizedBox(
              height: 60,
              width: 60,
              child: Stack(
                children: [
                  Center(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Center(
                    child: Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$completed / $total Tâches terminées",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progress == 1.0
                        ? "Tout est fini, bravo !"
                        : "Courage, continue !",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryComparison(
    BuildContext context,
    TasksProvider tasksProvider,
  ) {
    // Helper to calculate stats per category
    Widget buildRow(String label, TasksCategories category, Color color) {
      final allTasks =
          tasksProvider.allTasks.where((t) => t.category == category).toList();
      final total = allTasks.length;
      final completed = allTasks.where((t) => t.isCompleted).length;
      final pct = total == 0 ? 0.0 : completed / total;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${(pct * 100).toInt()}% ($completed/$total)"),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 12,
                backgroundColor: color.withOpacity(0.2),
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildRow(
              "Professionnel",
              TasksCategories.professional,
              AppTheme.professionalCategoryColor,
            ),
            const Divider(height: 24),
            buildRow(
              "Personnel",
              TasksCategories.personal,
              AppTheme.personalCategoryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, TasksProvider provider) {
    PieChartSectionData buildSection(ImportanceLevel imp, UrgencyLevel urg) {
      final count = provider.getGlobalTaskCount(imp, urg);
      final color = AppTheme.getQuadrantColor(importance: imp, urgency: urg);
      return PieChartSectionData(
        color: color,
        value: count.toDouble(),
        title: count > 0 ? '$count' : '',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }

    final totalActive = provider.tasks.length;
    if (totalActive == 0) {
      return const Center(child: Text("Pas de tâches actives."));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: [
          buildSection(ImportanceLevel.important, UrgencyLevel.urgent),
          buildSection(ImportanceLevel.notImportant, UrgencyLevel.urgent),
          buildSection(ImportanceLevel.notImportant, UrgencyLevel.notUrgent),
          buildSection(ImportanceLevel.important, UrgencyLevel.notUrgent),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    TasksProvider provider,
    ImportanceLevel imp,
    UrgencyLevel urg,
  ) {
    final color = AppTheme.getQuadrantColor(importance: imp, urgency: urg);
    // Shorten labels for the legend
    String shortLabel =
        "${getImportanceLevelName(imp)} / ${getUrgencyLevelName(urg)}";

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(shortLabel, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
