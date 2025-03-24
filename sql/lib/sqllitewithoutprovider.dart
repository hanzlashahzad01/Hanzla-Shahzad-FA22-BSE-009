// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   bool _isDarkMode = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadThemePreference();
//   }
//
//   // Load theme preference using SharedPreferences
//   void _loadThemePreference() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _isDarkMode = prefs.getBool('isDarkMode') ?? false;
//     });
//   }
//
//   // Toggle theme and save preference
//   void _toggleTheme() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _isDarkMode = !_isDarkMode;
//       prefs.setBool('isDarkMode', _isDarkMode);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
//       home: NotesScreen(toggleTheme: _toggleTheme),
//     );
//   }
// }
//
// class NotesScreen extends StatefulWidget {
//   final Function toggleTheme;
//   NotesScreen({required this.toggleTheme});
//
//   @override
//   _NotesScreenState createState() => _NotesScreenState();
// }
//
// class _NotesScreenState extends State<NotesScreen> {
//   late Database _database;
//   List<Map<String, dynamic>> _notes = [];
//   TextEditingController _noteController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _initDatabase();
//   }
//
//   // Initialize SQLite database
//   Future<void> _initDatabase() async {
//     _database = await openDatabase(
//       join(await getDatabasesPath(), 'notes.db'),
//       onCreate: (db, version) {
//         return db.execute(
//           "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT)",
//         );
//       },
//       version: 1,
//     );
//     _fetchNotes();
//   }
//
//   // Fetch notes from database
//   Future<void> _fetchNotes() async {
//     final List<Map<String, dynamic>> notes = await _database.query('notes');
//     setState(() {
//       _notes = notes;
//     });
//   }
//
//   // Add note to database
//   Future<void> _addNote() async {
//     if (_noteController.text.isNotEmpty) {
//       await _database.insert('notes', {'content': _noteController.text});
//       _noteController.clear();
//       _fetchNotes();
//     }
//   }
//
//   // Delete note from database
//   Future<void> _deleteNote(int id) async {
//     await _database.delete('notes', where: 'id = ?', whereArgs: [id]);
//     _fetchNotes();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notes Manager'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.brightness_6),
//             onPressed: () => widget.toggleTheme(),
//           )
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _noteController,
//                     decoration: InputDecoration(
//                       hintText: 'Enter a note',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.add),
//                   onPressed: _addNote,
//                 )
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _notes.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_notes[index]['content']),
//                   trailing: IconButton(
//                     icon: Icon(Icons.delete),
//                     onPressed: () => _deleteNote(_notes[index]['id']),
//                   ),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
