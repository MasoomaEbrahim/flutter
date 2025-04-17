import 'package:flutter/material.dart';
import 'todo_app.dart';

class CompletedTasksScreen extends StatelessWidget {
  final List<Task> tasks;

  CompletedTasksScreen({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((task) => task.progress == 'Completed').toList();

    return Scaffold(
      appBar: AppBar(title: Text('Completed Tasks'),
      backgroundColor: const Color.fromARGB(255, 240, 124, 163),
      ),
      body: completedTasks.isEmpty
          ? Center(child: Text('No completed tasks yet!'))
          : ListView.builder(
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(completedTasks[index].title),
                    subtitle: Text('Due: ${completedTasks[index].dueDate.toLocal()}'),
                  ),
                );
              },
            ),
    );
  }
}