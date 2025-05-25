import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../models/report.dart';
import '../utils/constants.dart'; // For storing Supabase URL and keys

class SupabaseService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  late final SupabaseClient _adminClient;

  SupabaseService() {
    _adminClient = SupabaseClient(Constants.supabaseUrl, Constants.supabaseServiceRoleKey);
  }

  // Admin Login
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('Invalid email or password');
      }
      final userData = await _client.from('users').select().eq('id', response.user!.id).maybeSingle();
      print('Login query result: $userData');
      if (userData == null) {
        await _client.auth.signOut();
        throw Exception('User not found in the database. Please contact support.');
      }
      if (userData['role'] != 'admin') {
        await _client.auth.signOut();
        throw Exception('Only admin users can log in.');
      }
      print('Login successful: ${userData['email']}');
      notifyListeners();
      return {
        'session': response.session,
      };
    } catch (e) {
      print('Login error: $e');
      throw Exception(e.toString());
    }
  }

  // Add Student
  Future<void> addStudent(String name, String email, String password) async {
    try {
      final response = await _adminClient.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          userMetadata: {'name': name, 'role': 'student'},
        ),
      );
      if (response.user == null) {
        throw Exception('Failed to create user in auth');
      }
      await _client.from('users').insert({
        'id': response.user!.id,
        'name': name,
        'email': email,
        'role': 'student',
      });
      print('Student added: $email');
      notifyListeners();
    } catch (e) {
      print('Add student error: $e');
      throw Exception('Failed to add student: $e');
    }
  }

  // Get All Students
  Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      print('Querying students from users table...');
      final response = await _client.from('users').select().ilike('role', 'student');
      print('Get students response (raw): $response');
      if (response == null || response.isEmpty) {
        print('No students found in response');
        return [];
      }
      final students = List<Map<String, dynamic>>.from(response);
      print('Parsed students: $students');
      return students;
    } catch (e) {
      print('Get students error: $e');
      return [];
    }
  }

  // Delete Student
  Future<void> deleteStudent(String studentId) async {
    try {
      await _client.from('tasks').delete().eq('assigned_to', studentId);
      await _client.from('reports').delete().eq('student_id', studentId);
      await _client.from('users').delete().eq('id', studentId);
      await _adminClient.auth.admin.deleteUser(studentId);
      print('Student deleted: $studentId');
      notifyListeners();
    } catch (e) {
      print('Delete student error: $e');
      throw Exception('Failed to delete student: $e');
    }
  }

  // Assign Task
  Future<void> assignTask(
      String title,
      String description,
      String studentId,
      DateTime dueDate,
      ) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }
      final userData = await _client.from('users').select().eq('id', currentUser.id).single();
      if (userData['role'] != 'admin') {
        throw Exception('User not authorized to assign tasks');
      }
      await _client.from('tasks').insert({
        'title': title,
        'description': description.isEmpty ? null : description,
        'assigned_to': studentId,
        'status': 'pending',
        'due_date': dueDate.toIso8601String(),
        'created_by': currentUser.id,
      });
      print('Task assigned to student: $studentId');
      notifyListeners();
    } catch (e) {
      print('Assign task error: $e');
      throw Exception('Failed to assign task: $e');
    }
  }

  // Get Tasks for a Student
  Future<List<Map<String, dynamic>>> getTasksForStudent(String studentId) async {
    try {
      final response = await _client.from('tasks').select().eq('assigned_to', studentId);
      print('Get tasks response: $response');
      if (response == null || response.isEmpty) {
        print('No tasks found for student: $studentId');
        return [];
      }
      final tasks = List<Map<String, dynamic>>.from(response);
      print('Parsed tasks: $tasks');
      return tasks;
    } catch (e) {
      print('Get tasks error: $e');
      return [];
    }
  }

  // Get Reports
  Future<List<Report>> getReports() async {
    try {
      final response = await _client.from('reports').select();
      print('Get reports response: $response');
      if (response == null || response.isEmpty) {
        print('No reports found in response');
        return [];
      }
      final reports = response.map((json) => Report.fromJson(json)).toList();
      print('Parsed reports: $reports');
      return reports;
    } catch (e) {
      print('Get reports error: $e');
      return [];
    }
  }
}