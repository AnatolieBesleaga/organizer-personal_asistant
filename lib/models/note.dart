import 'package:hive/hive.dart';
part 'note.g.dart';

@HiveType(typeId: 1)
class Note extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String body;

  @HiveField(2)
  int? color;

  @HiveField(3)
  String? tag;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  @HiveField(6)
  DateTime? reminder;

  Note({
    required this.title,
    required this.body,
    this.color,
    this.tag,
    DateTime? createdAt,
    this.updatedAt,
    this.reminder,
  }) : createdAt = createdAt ?? DateTime.now();
}