import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class AgendaPage extends StatelessWidget {
  final String userName = 'Anatolie'; // Change if needed

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    final taskBox = Hive.box<Task>('tasksBox');

    // 🔍 Filter only tasks due today
    final tasks = taskBox.values
        .where((task) =>
            task.dueDate.year == DateTime.now().year &&
            task.dueDate.month == DateTime.now().month &&
            task.dueDate.day == DateTime.now().day)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $userName 👋',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            "Today is $today",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 16),
          Text(
            "Your Tasks Today:",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Expanded(
            child: tasks.isEmpty
                ? Text("You're all caught up today! 🎉")
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (_, index) {
                      final task = tasks[index]; // ✅ Define the task here
                      return Card(
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Text(
                            'Due: ${DateFormat.yMMMd().format(task.dueDate)}',
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
