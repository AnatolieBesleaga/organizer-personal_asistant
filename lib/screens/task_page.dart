import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskPage extends StatefulWidget {
  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;

  final Box<Task> taskBox = Hive.box<Task>('tasksBox');

  void _addTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedDate == null) return;

    final task = Task(title: title, dueDate: _selectedDate!);
    taskBox.add(task);

    _titleController.clear();
    setState(() {
      _selectedDate = null;
    });
  }

  void _removeTask(int index) {
    taskBox.deleteAt(index);
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = taskBox.values.toList();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Task title',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: _addTask,
              ),
            ),
            onSubmitted: (_) => _addTask(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(_selectedDate == null
                  ? 'No date chosen'
                  : 'Due: ${DateFormat.yMMMd().format(_selectedDate!)}'),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _pickDate,
                child: Text('Pick Date'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, index) {
                final task = tasks[index];
                return Card(
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      'Due: ${DateFormat.yMMMd().format(task.dueDate)}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeTask(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
