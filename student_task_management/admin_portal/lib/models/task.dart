class Task {
  final String id;
  final String title;
  final String? description;
  final String assignedTo;
  final String status;
  final DateTime dueDate;
  final String createdBy;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.assignedTo,
    required this.status,
    required this.dueDate,
    required this.createdBy,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    print('Task JSON: $json'); // Debug log
    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      assignedTo: json['assigned_to']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assigned_to': assignedTo,
      'status': status,
      'due_date': dueDate.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}