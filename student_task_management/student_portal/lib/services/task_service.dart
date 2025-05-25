import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getStudentTasks(String studentId) async {
    final response = await _supabase
        .from('tasks')
        .select()
        .eq('student_id', studentId)
        .order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markTaskComplete(String taskId) async {
    await _supabase
        .from('tasks')
        .update({'status': 'completed'})
        .eq('id', taskId);
  }
}