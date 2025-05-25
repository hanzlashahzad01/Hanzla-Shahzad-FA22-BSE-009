class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('Raw User JSON: $json'); // Debug log
    try {
      return User(
        id: json['id']?.toString() ?? 'unknown_id',
        name: json['name']?.toString() ?? 'Unknown',
        email: json['email']?.toString() ?? 'no_email',
        role: json['role']?.toString() ?? 'student',
      );
    } catch (e) {
      print('Error parsing User JSON: $e, JSON: $json'); // Detailed error log
      return User(
        id: 'error_id',
        name: 'Error',
        email: 'error@example.com',
        role: 'student',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }
}