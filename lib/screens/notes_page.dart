import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';


class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
    String _searchQuery = '';
    String _sortOption = 'Latest';
    final List<String> _tags = ['Work', 'Personal', 'Idea', 'Family', 'Other'];
    final List<String> _sortOptions = ['Latest', 'A-Z'];
Note? _editingNote;
String? _selectedTag;
DateTime? _reminderTime;

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _notesBox = Hive.box<Note>('notesBox');
Color _selectedColor = Colors.amber;
Future<void> _addNote() async {
  if (_titleController.text.trim().isEmpty) return;

if (_reminderTime != null) {
  await NotificationService.showReminder(
    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title: _titleController.text.trim(),
    body: _bodyController.text.trim(),
    scheduledTime: _reminderTime!,
  );
}

  if (_editingNote != null) {
    // Update existing note
    _editingNote!
      ..title = _titleController.text.trim()
      ..body = _bodyController.text.trim()
      ..color = _selectedColor.value
      ..tag = _selectedTag
      ..updatedAt = DateTime.now()
      ..save(); // Hive persist update
  } else {
    // Add new note
final note = Note(
  title: _titleController.text.trim(),
  body: _bodyController.text.trim(),
  color: _selectedColor.value,
  tag: _selectedTag,
  createdAt: DateTime.now(),
  reminder: _reminderTime, // ✅ add this line
);
    _notesBox.add(note);
  }

  _clearForm();
  setState(() {});
}
void _editNote(Note note) {
  _titleController.text = note.title;
  _bodyController.text = note.body;
  _selectedColor = Color(note.color ?? Colors.amber.value);
  _selectedTag = note.tag;
  _editingNote = note;

  setState(() {});
}
void _clearForm() {
  _titleController.clear();
  _bodyController.clear();
  _selectedTag = null;
  _selectedColor = Colors.amber;
  _editingNote = null;
}

  void _showEditDialog(BuildContext context, Note note, int index) {
  final editTitleController = TextEditingController(text: note.title);
  final editBodyController = TextEditingController(text: note.body);
  String? selectedTag = note.tag;
  Color selectedColor = Color(note.color ?? Colors.amber.value);

  showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Edit Note'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: editTitleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: editBodyController,
            decoration: InputDecoration(labelText: 'Body'),
          ),
          DropdownButtonFormField<String>(
            value: selectedTag,
            decoration: InputDecoration(labelText: 'Tag'),
            items: _tags
                .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                .toList(),
            onChanged: (value) => selectedTag = value,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text("Color:"),
              SizedBox(width: 10),
              ...[
                Colors.amber,
                Colors.lightBlue,
                Colors.green,
                Colors.pinkAccent,
                Colors.purple
              ].map((color) {
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selectedColor == color
                          ? Border.all(width: 2, color: Colors.black)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(Duration(minutes: 5)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );

              if (selectedDate != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (time != null) {
                  setState(() {
                    _reminderTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }
            },
            child: Text(_reminderTime == null
                ? "Set Reminder"
                : "Reminder: ${DateFormat.yMd().add_jm().format(_reminderTime!)}"),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
      ElevatedButton(
        onPressed: () {
          final updatedNote = Note(
            title: editTitleController.text.trim(),
            body: editBodyController.text.trim(),
            tag: selectedTag,
            color: selectedColor.value,
            reminder: _reminderTime,
            updatedAt: DateTime.now(),
          );
          _notesBox.putAt(index, updatedNote);
          setState(() {});
          Navigator.pop(context);
        },
        child: Text("Save"),
      ),
    ],
  ),
);
  }


  void _deleteNote(int index) {
    _notesBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
final allNotes = _notesBox.values.toList();

final filtered = allNotes.where((note) {
  final titleMatch = note.title.toLowerCase().contains(_searchQuery);
  final tagMatch = (note.tag ?? '').toLowerCase().contains(_searchQuery);
  return titleMatch || tagMatch;
}).toList();

if (_sortOption == 'A-Z') {
  filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
} else {
  // Default sort = Latest
  filtered.sort((a, b) => b.key.compareTo(a.key)); // Higher key = newer
}

final notes = filtered;



    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _bodyController,
            decoration: InputDecoration(labelText: 'Body'),
          ),
          DropdownButtonFormField<String>(
  value: _selectedTag,
  decoration: InputDecoration(labelText: 'Tag'),
  items: _tags
      .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
      .toList(),
  onChanged: (value) => setState(() => _selectedTag = value),
),

          SizedBox(height: 10),
Row(
  children: [
    Text("Color:"),
    SizedBox(width: 10),
    ...[
      Colors.amber,
      Colors.lightBlue,
      Colors.green,
      Colors.pinkAccent,
      Colors.purple
    ].map((color) {
      return GestureDetector(
        onTap: () {
          setState(() => _selectedColor = color);
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: _selectedColor == color
                ? Border.all(width: 2, color: Colors.black)
                : null,
          ),
        ),
      );
    }).toList(),
  ],
),
 DropdownButtonFormField<String>(
          value: _sortOption,
          decoration: InputDecoration(labelText: 'Sort Notes'),
          items: _sortOptions
              .map((option) => DropdownMenuItem(value: option, child: Text(option)))
              .toList(),
          onChanged: (value) => setState(() => _sortOption = value!),
        ),

        SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addNote,
            child: Text('Add Note'),
          ),
          SizedBox(height: 20),
          TextField(
  decoration: InputDecoration(
    labelText: 'Search by title or tag',
    prefixIcon: Icon(Icons.search),
  ),
  onChanged: (value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  },
),
SizedBox(height: 10),
    Expanded(
  child: notes.isEmpty
      ? Center(child: Text("No notes yet."))
      : ListView.builder(
          itemCount: notes.length,
          itemBuilder: (_, index) {
            final note = notes[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Color(note.color ?? Colors.grey.shade200.value),
              elevation: 4,
child: InkWell(
  onTap: () => _showEditDialog(context, note, index),
  child: ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    title: Text(
      note.title,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
   subtitle: Text(
  '${note.body}\nTag: ${note.tag ?? 'None'}\nCreated: ${DateFormat.yMMMd().format(note.createdAt)}',
),

trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: Icon(Icons.edit, color: Colors.blueAccent),
      onPressed: () => _editNote(note),
    ),
    IconButton(
      icon: Icon(Icons.delete, color: Colors.redAccent),
      onPressed: () => _deleteNote(index),
    ),
  ],
),

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
