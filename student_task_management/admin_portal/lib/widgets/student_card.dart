import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onDelete;
  final bool isLoading;

  const StudentCard({
    super.key,
    required this.student,
    required this.onDelete,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = student['name']?.toString() ?? 'Unnamed Student';
    final email = student['email']?.toString() ?? 'No email';

    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentColor,
          child: Text(
            name.isNotEmpty ? name[0] : '?',
            style: const TextStyle(color: Colors.black),
          ),
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(email),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: isLoading ? null : onDelete,
        ),
      ),
    );
  }
}