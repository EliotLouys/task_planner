import 'package:flutter/material.dart';
import 'package:zbeub_task_plan/ui/selection_page/selection_page.dart';




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
            // --- First Button: Tâches pros ---
            // Sizing/Style is now handled by ElevatedButtonThemeData
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,SelectionPage.route('tâches pro'),);
              },
              child: const Text(
                'Tâches pros',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20), // Espacement entre les boutons
            // --- Second Button: Tâches persos ---
            // Sizing/Style is now handled by ElevatedButtonThemeData
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,SelectionPage.route('tâches persos'),);
              },
              child: const Text(
                'Tâches persos',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )
      ),
    );
  }
}
