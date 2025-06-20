import '../../services/complaint_service.dart';

enum ComplaintStatus {
  submitted,
  inProgress,
  escalatedToHod,
  resolved,
  rejected
}

class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String studentId;
  final String studentName;
  final String studentBatch;
  final String? imageUrl;
  final String? videoUrl;
  final ComplaintStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? currentHandlerId;
  final String? currentHandlerName;
  final List<ComplaintComment> comments;
  final String priority;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.studentId,
    required this.studentName,
    required this.studentBatch,
    this.imageUrl,
    this.videoUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.currentHandlerId,
    this.currentHandlerName,
    required this.comments,
    required this.priority,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String,
      studentBatch: json['student_batch'] as String,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      status: ComplaintStatus.values.firstWhere(
        (e) => e.toString() == 'ComplaintStatus.${json['status']}',
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      currentHandlerId: json['current_handler_id'] as String?,
      currentHandlerName: json['current_handler_name'] as String?,
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((e) => ComplaintComment.fromJson(e as Map<String, dynamic>))
          .toList(),
      priority: json['priority'] as String? ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Removed for DB auto-generation
      'title': title,
      'description': description,
      'student_id': studentId,
      'student_name': studentName,
      'student_batch': studentBatch,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'current_handler_id': currentHandlerId,
      'current_handler_name': currentHandlerName,
      'priority': priority,
    };
  }
}

class ComplaintComment {
  final String id;
  final String userId;
  final String userName;
  final String comment;
  final DateTime createdAt;
  final String userRole;

  ComplaintComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.createdAt,
    required this.userRole,
  });

  factory ComplaintComment.fromJson(Map<String, dynamic> json) {
    return ComplaintComment(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userRole: json['user_role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Removed for DB auto-generation
      'user_id': userId,
      'user_name': userName,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'user_role': userRole,
    };
  }
} 