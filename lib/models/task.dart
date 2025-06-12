import 'package:hive/hive.dart';

part 'task.g.dart'; // Hive will generate this

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime dueDate;

  Task({required this.title, required this.dueDate});
}
