import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../widgets/neon_button.dart';

class TaskAssignmentScreen extends StatefulWidget {
  const TaskAssignmentScreen({super.key});

  @override
  State<TaskAssignmentScreen> createState() => _TaskAssignmentScreenState();
}

class _TaskAssignmentScreenState extends State<TaskAssignmentScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  Map<String, dynamic>? _selectedStudent;
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final students = await Provider.of<SupabaseService>(context, listen: false).getStudents();
      print('Fetched students in UI: $students');
      setState(() {
        _students = students.isNotEmpty ? students : [];
      });
      if (students.isEmpty) {
        setState(() {
          _errorMessage = 'No students available to assign tasks';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching students: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _assignTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedStudent == null || _dueDate == null) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Provider.of<SupabaseService>(context, listen: false).assignTask(
        title,
        _descriptionController.text.trim(),
        _selectedStudent!['id'],
        _dueDate!,
      );
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _dueDate = null;
        _selectedStudent = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task assigned successfully')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error assigning task: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Task'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6200EA), Color(0xFF03DAC6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        decoration: const InputDecoration(
                          labelText: 'Assign To',
                        ),
                        items: _students.map((student) {
                          return DropdownMenuItem(
                            value: student,
                            child: Text(student['name']?.toString() ?? 'Unnamed Student'),
                          );
                        }).toList(),
                        value: _selectedStudent,
                        onChanged: _isLoading ? null : (value) => setState(() => _selectedStudent = value),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => _dueDate = picked);
                          }
                        },
                        child: Text(
                          _dueDate == null ? 'Select Due Date' : DateFormat.yMMMd().format(_dueDate!),
                        ),
                      ),
                      const SizedBox(height: 16),
                      NeonButton(
                        text: 'Assign Task',
                        onPressed: _assignTask,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}