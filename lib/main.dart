import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/theme/app_theme.dart';
import 'package:zbeub_task_plan/ui/home_page/home_page.dart';
import 'package:zbeub_task_plan/data/tasks.dart';
import 'package:zbeub_task_plan/data/today_tasks.dart'; // Import new provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final tasksProvider = TasksProvider();
  final todayTasksProvider = TodayTasksProvider();

  // 1. Establish the links between providers
  tasksProvider.setTodayTasksProvider(todayTasksProvider); 
  todayTasksProvider.setTasksProvider(tasksProvider); // New link for loading

  // 2. Load Main Tasks first
  await tasksProvider.loadTasks(); 

  // 3. Load Today's Tasks (which depends on the main task list)
  await todayTasksProvider.loadTasksForToday();
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