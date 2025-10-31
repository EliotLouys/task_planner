import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/theme/app_theme.dart';
import 'package:zbeub_task_plan/ui/home_page/home_page.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/data/today_tasks.dart'; // Import new provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final tasksProvider = TasksProvider();
  final todayTasksProvider = TodayTasksProvider(); // Initialize new provider

  // Establish link between providers
  tasksProvider.setTodayTasksProvider(todayTasksProvider); 

  await tasksProvider.loadTasks(); // Load tasks on startup

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: tasksProvider),
        ChangeNotifierProvider.value(value: todayTasksProvider), // Provide new provider
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ton planner perso hihi',
      theme: AppTheme.lightTheme,
      home: const MyHomePage(title: 'Le ptit tablo'),
    );
  }
}