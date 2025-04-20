import 'package:taskmanagement/screens/add_task_screen.dart';
import 'package:taskmanagement/screens/home_screen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      routes: {
        '/add-task': (context) => const AddTaskScreen(),
      },
    );
  }
}