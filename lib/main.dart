import 'screens/task_page.dart';
import 'screens/agenda_page.dart';
import 'screens/calendar_page.dart';
import 'screens/notes_page.dart';
import 'dart:io'; // ⬅️ Needed for Directory and Platform
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/task.dart';
import 'screens/notes_page.dart';
import 'models/note.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Directory appDocDir;
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    appDocDir = await getApplicationSupportDirectory();
  } else {
    appDocDir = await getApplicationDocumentsDirectory();
  }

  print('📁 Hive path: ${appDocDir.path}'); // ✅ This line is safe and correct

  await Hive.initFlutter(appDocDir.path);
  
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Task>('tasksBox');
  await Hive.openBox<Note>('notesBox');
  await NotificationService.init();

  runApp(PersonalAssistantApp());
}



class PersonalAssistantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Assistant',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomeScreen(),
    );
  }
}



class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    AgendaPage(),
   TaskPage(),
   CalendarPage(),
   NotesPage(),
  ];

  final List<String> _titles = ['Agenda', 'Tasks', 'Calendar', 'Notes'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.view_agenda), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
