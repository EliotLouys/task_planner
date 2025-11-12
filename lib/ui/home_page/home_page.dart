import 'package:flutter/material.dart';
import 'package:zbeub_task_plan/theme/app_theme.dart';
import 'package:zbeub_task_plan/ui/selection_page/selection_page.dart';
import 'package:zbeub_task_plan/ui/task_page/archive_page.dart';
import 'package:zbeub_task_plan/ui/task_page/today_task_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // AppBar style is now managed by AppTheme
        title: Text(widget.title),
        ),
      body: Center(
        child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- First Button: Tâches pros (New Color) ---
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, SelectionPage.route('tâches pro'),);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.professionalCategoryColor, // Professional color (Blue)
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Tâches pros',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20), // Espacement entre les boutons
            
            // --- Second Button: Tâches persos (New Color) ---
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, SelectionPage.route('tâches persos'),);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.personalCategoryColor, // Personal color (Red/Pink)
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Tâches persos',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40), // More spacing for the third button

            // --- Third Button: Today's Tasks ---
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, TodayTasksPage.route(),); // Navigation to the new page
              },
              // This button uses the default ElevatedButton theme defined in AppTheme
              child: const Text(
                "Tâches pour Aujourd'hui",
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 40), // More spacing for the third button

            ElevatedButton(
              onPressed: () {
                Navigator.push(context, ArchivePage.route(),); // Navigation to Archive Page
              },
              child: const Text(
                "Archives",
                textAlign: TextAlign.center,
              ),
            ),
            

          ],
        )
      ),
    );
  }
}