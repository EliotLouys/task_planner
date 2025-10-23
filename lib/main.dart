import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zbeub_task_plan/theme/app_theme.dart';
import 'package:zbeub_task_plan/ui/home_page/home_page.dart';
import 'package:zbeub_task_plan/data/tasks.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TasksProvider(),
      child:const MyApp()
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
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

