class AppUser {
  final int id;
  final String name;
  final String email;
  final String role; // admin أو student

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
    );
  }

  Map<String, dynamic> toMapForInsert({
    required String password,
    String? phone,
  }) {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone': phone,
    };
  }
}
