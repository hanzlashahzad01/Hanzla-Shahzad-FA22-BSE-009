class Report {
  final String id;
  final String studentId;
  final int completedTasks;
  final int pendingTasks;
  final int performanceScore;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.studentId,
    required this.completedTasks,
    required this.pendingTasks,
    required this.performanceScore,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    print('Report JSON: $json'); // Debug log
    return Report(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      completedTasks: json['completed_tasks'] is int ? json['completed_tasks'] : 0,
      pendingTasks: json['pending_tasks'] is int ? json['pending_tasks'] : 0,
      performanceScore: json['performance_score'] is int ? json['performance_score'] : 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'completed_tasks': completedTasks,
      'pending_tasks': pendingTasks,
      'performance_score': performanceScore,
      'created_at': createdAt.toIso8601String(),
    };
  }
}