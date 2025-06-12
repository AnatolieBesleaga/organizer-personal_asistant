import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Task> _getTasksForDay(DateTime day) {
    final taskBox = Hive.box<Task>('tasksBox');
    return taskBox.values.where((task) {
      return task.dueDate.year == day.year &&
          task.dueDate.month == day.month &&
          task.dueDate.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _getTasksForDay(_selectedDay ?? _focusedDay);

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Tasks on ${DateFormat.yMMMd().format(_selectedDay ?? _focusedDay)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Expanded(
          child: tasks.isEmpty
              ? Center(child: Text("No tasks on this day."))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (_, index) {
                    final task = tasks[index];
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
    );
  }
}
