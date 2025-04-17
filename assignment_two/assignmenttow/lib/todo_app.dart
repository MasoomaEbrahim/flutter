import 'package:flutter/material.dart';
import 'completed_tasks.dart';

class Task {
  String title;
  String description;
  String duration;
  String progress;
  DateTime dueDate;

  Task({
    required this.title,
    this.description = '',
    this.duration = '',
    this.progress = 'Not Started',
    required this.dueDate,
  });
}

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final List<Task> _tasks = [];
  int _currentIndex = 0;

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
    _showSnackBar('Task added successfully!');
  }

  void _updateTaskProgress(int index, String newProgress) {
    setState(() {
      _tasks[index].progress = newProgress;
    });
    _showSnackBar('Task progress updated to $newProgress!');
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _showSnackBar('Task deleted successfully!');
  }

  void _editTaskTitle(int index, String newTitle) {
    setState(() {
      _tasks[index].title = newTitle;
    });
    _showSnackBar('Task title updated successfully!');
  }

  void _navigateToCompletedTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletedTasksScreen(tasks: _tasks),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        backgroundColor: const Color.fromARGB(255, 240, 124, 163),
        actions: [
          IconButton(
            icon: Icon(Icons.check_circle),
            onPressed: _navigateToCompletedTasks,
          ),
        ],
      ),
      body: _currentIndex == 0
          ? AddTaskScreen(onAddTask: _addTask)
          : TaskManagementScreen(
              tasks: _tasks,
              onUpdateProgress: _updateTaskProgress,
              onDeleteTask: _deleteTask,
              onEditTitle: _editTaskTitle,
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Task'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Manage Tasks'),
        ],
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  final Function(Task) onAddTask;

  AddTaskScreen({required this.onAddTask});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  DateTime? dueDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Task Title'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: durationController,
            decoration: InputDecoration(labelText: 'Duration'),
          ),
          TextField(
            readOnly: true,
            decoration: InputDecoration(labelText: 'Due Date', hintText: 'Tap to select'),
            onTap: () async {
              dueDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (dueDate != null) {
                setState(() {}); // Update UI when the due date is selected
              }
            },
            controller: TextEditingController(text: dueDate != null ? dueDate!.toLocal().toString().split(' ')[0] : ''),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && dueDate != null) {
                widget.onAddTask(Task(
                  title: titleController.text,
                  description: descriptionController.text,
                  duration: durationController.text,
                  progress: 'Not Started', // Default progress
                  dueDate: dueDate!,
                ));
                titleController.clear();
                descriptionController.clear();
                durationController.clear();
                dueDate = null;
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Please fill all required fields.')));
              }
            },
            child: Text('Add Task'),
          ),
        ],
      ),
    );
  }
}

class TaskManagementScreen extends StatelessWidget {
  final List<Task> tasks;
  final Function(int, String) onUpdateProgress;
  final Function(int) onDeleteTask;
  final Function(int, String) onEditTitle;

  TaskManagementScreen({required this.tasks, required this.onUpdateProgress, required this.onDeleteTask, required this.onEditTitle});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(tasks[index].title),
            subtitle: Text('Due: ${tasks[index].dueDate.toLocal()} - Progress: ${tasks[index].progress}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditDialog(context, index);
                  },
                ),
                DropdownButton<String>(
                  value: tasks[index].progress,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      onUpdateProgress(index, newValue);
                    }
                  },
                  items: <String>[
                    'Not Started',
                    'In Progress',
                    'Completed',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Delete Task'),
                          content: Text('Are you sure you want to delete this task?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                onDeleteTask(index);
                                Navigator.of(context).pop();
                              },
                              child: Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('No'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    final TextEditingController editController = TextEditingController(text: tasks[index].title);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task Title'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(labelText: 'New Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  onEditTitle(index, editController.text);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Title cannot be empty.')));
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}