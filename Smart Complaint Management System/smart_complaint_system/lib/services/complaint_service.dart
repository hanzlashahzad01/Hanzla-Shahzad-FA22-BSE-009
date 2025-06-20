import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_config.dart';
import '../models/complaint_model.dart';

class ComplaintService {
  final _supabase = Supabase.instance.client;

  Future<void> submitComplaint(ComplaintModel complaint) async {
    await _supabase.from(AppConfig.complaintsTable).insert(complaint.toJson());
  }

  Future<List<ComplaintModel>> getStudentComplaints(String studentId) async {
    final response = await _supabase
        .from(AppConfig.complaintsTable)
        .select()
        .eq('student_id', studentId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ComplaintModel.fromJson(json))
        .toList();
  }

  Future<List<ComplaintModel>> getBatchAdvisorComplaints(
    String batchAdvisorEmail,
  ) async {
    final response = await _supabase
        .from(AppConfig.complaintsTable)
        .select()
        .eq('batch_advisor_email', batchAdvisorEmail)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ComplaintModel.fromJson(json))
        .toList();
  }

  Future<List<ComplaintModel>> getHodComplaints(String department) async {
    final response = await _supabase
        .from(AppConfig.complaintsTable)
        .select()
        .eq('department', department)
        .eq('status', ComplaintStatus.escalatedToHod.toString().split('.').last)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ComplaintModel.fromJson(json))
        .toList();
  }

  Future<void> updateComplaintStatus(
    String complaintId,
    ComplaintStatus status,
    String? handlerId,
    String? handlerName,
  ) async {
    await _supabase.from(AppConfig.complaintsTable).update({
      'status': status.toString().split('.').last,
      'current_handler_id': handlerId,
      'current_handler_name': handlerName,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', complaintId);
  }

  Future<void> addComment(
    String complaintId,
    ComplaintComment comment,
  ) async {
    await _supabase.from(AppConfig.commentsTable).insert({
      ...comment.toJson(),
      'complaint_id': complaintId,
    });
  }

  Future<List<ComplaintComment>> getComplaintComments(String complaintId) async {
    final response = await _supabase
        .from(AppConfig.commentsTable)
        .select()
        .eq('complaint_id', complaintId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ComplaintComment.fromJson(json))
        .toList();
  }

  Future<Map<String, dynamic>> getComplaintStats(String userId, String role) async {
    final query = _supabase.from(AppConfig.complaintsTable).select();

    switch (role) {
      case 'student':
        query.eq('student_id', userId);
        break;
      case 'batch_advisor':
        query.eq('batch_advisor_email', userId);
        break;
      case 'hod':
        query.eq('department', userId);
        break;
      default:
        throw Exception('Invalid role');
    }

    final response = await query;
    final complaints = (response as List)
        .map((json) => ComplaintModel.fromJson(json))
        .toList();

    return {
      'total': complaints.length,
      'submitted': complaints
          .where((c) => c.status == ComplaintStatus.submitted)
          .length,
      'inProgress': complaints
          .where((c) => c.status == ComplaintStatus.inProgress)
          .length,
      'escalated': complaints
          .where((c) => c.status == ComplaintStatus.escalatedToHod)
          .length,
      'resolved': complaints
          .where((c) => c.status == ComplaintStatus.resolved)
          .length,
      'rejected': complaints
          .where((c) => c.status == ComplaintStatus.rejected)
          .length,
    };
  }

  Future<List<ComplaintModel>> getAllComplaints() async {
    final response = await _supabase
        .from(AppConfig.complaintsTable)
        .select()
        .order('created_at', ascending: false);
    return (response as List)
        .map((json) => ComplaintModel.fromJson(json))
        .toList();
  }
} 