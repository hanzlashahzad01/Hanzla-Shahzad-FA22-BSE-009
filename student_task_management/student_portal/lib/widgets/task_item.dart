import 'package:flutter/material.dart';

class TaskItem extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onComplete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task['status'] == 'completed';
    final dueDate = task['due_date'] != null
        ? DateTime.parse(task['due_date'])
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          task['title'],
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task['description'] != null)
              Text(
                task['description'],
                style: const TextStyle(fontSize: 14),
              ),
            if (dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Checkbox(
          value: isCompleted,
          onChanged: isCompleted ? null : (value) => onComplete(),
        ),
      ),
    );
  }
}