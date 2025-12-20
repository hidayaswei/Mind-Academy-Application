class Teacher {
  final int? id;
  final String name;
  final String? phone;
  final String? specialization;

  Teacher({
    this.id,
    required this.name,
    this.phone,
    this.specialization,
  });

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      specialization: map['specialization'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'specialization': specialization,
    };
  }
}