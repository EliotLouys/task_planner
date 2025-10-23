import 'package:flutter/material.dart';
import 'package:zbeub_task_plan/ui/home_page/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ton planner perso hihi',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 190, 250, 203)),
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

