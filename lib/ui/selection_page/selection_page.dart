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

class SelectionPage extends StatefulWidget{

  const SelectionPage({super.key, required this.title});

  final String title;

  static Route<void> route(String title) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/SelectionPage'),
      builder: (_) => SelectionPage(title: title ),
    );
  }

  @override
  State<SelectionPage> createState() => _SelectionPageState();
  
}

class _SelectionPageState extends State<SelectionPage>{
  
  Widget _buildClickableCard({
    required String title,
    required String subtitle,
    required String numberOfItemsOfMatrix,
    required Color color,
    required VoidCallback onTap,
  }) {
    return 
    Card(
      elevation: 5, // Adds a shadow effect
      margin: const EdgeInsets.all(8.0), // Space around the card
      color: color,
      child: InkWell(
        // Makes the entire card clickable
        onTap: onTap,
        splashColor: Colors.white70, // Visual feedback when tapped
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // First line (Title)
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Second line (Subtitle/Detail)
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                numberOfItemsOfMatrix,
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes des ${widget.title}'),
      ),
      // GridView fills the remaining screen space
      body: GridView.count(
        // Creates a 2x2 grid (2 columns)
        crossAxisCount: 2,
        // The children will be equally sized to fill the space
        children: <Widget>[
          // --- Card 1 ---
          _buildClickableCard(
            subtitle: 'Important',
            title: 'Urgent',
            numberOfItemsOfMatrix: 'Tâches restantes : ${context.read<TasksProvider>().getNumberOfTasks(ImportanceLevel.important,UrgencyLevel.urgent, _stringToCategory(widget.title),)}',
            color: AppTheme.urgentImportantColor,
            onTap: () {
              Navigator.push(
                context,
                // Updated navigation to new list page
                AllTasksPage.route(
                  widget.title,
                  ImportanceLevel.important,
                  UrgencyLevel.urgent,
                ),
              );
            },
          ),
          

          
          // --- Card 3 ---
          _buildClickableCard(
            subtitle: 'Pas important',
            title: 'Urgent',
            numberOfItemsOfMatrix: 'Tâches restantes : ${context.read<TasksProvider>().getNumberOfTasks(ImportanceLevel.notImportant,UrgencyLevel.urgent, _stringToCategory(widget.title),)}',
            color: AppTheme.urgentNotImportantColor,
            onTap: () {
              Navigator.push(
                context,
                // Updated navigation to new list page
                AllTasksPage.route(
                  widget.title,
                  ImportanceLevel.notImportant,
                  UrgencyLevel.urgent,
                ),
              );
            },
          ),
          
                    // --- Card 2 ---
          _buildClickableCard(
            subtitle: 'Important',
            title: 'Pas urgent',
            numberOfItemsOfMatrix: 'Tâches restantes : ${context.read<TasksProvider>().getNumberOfTasks(ImportanceLevel.important,UrgencyLevel.notUrgent, _stringToCategory(widget.title),)}',
            color: AppTheme.importantNotUrgentColor,
            onTap: () {
              Navigator.push(
                context,
                // Updated navigation to new list page
                AllTasksPage.route(
                  widget.title,
                  ImportanceLevel.important,
                  UrgencyLevel.notUrgent,
                ),
              );
            },
          ),
          // --- Card 4 ---
          _buildClickableCard(
            subtitle: 'Pas important',
            title: 'Pas urgent',
            numberOfItemsOfMatrix: 'Tâches restantes : ${context.read<TasksProvider>().getNumberOfTasks(ImportanceLevel.notImportant,UrgencyLevel.notUrgent, _stringToCategory(widget.title),)}',
            color: AppTheme.notUrgentNotImportantColor,
            onTap: () {
              Navigator.push(
                context,
                // Updated navigation to new list page
                  AllTasksPage.route(
                  widget.title,
                  ImportanceLevel.notImportant,
                  UrgencyLevel.notUrgent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


