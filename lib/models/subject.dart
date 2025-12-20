class Subject {
  final int id;
  final String name;
  final String? description;

  Subject({
    required this.id,
    required this.name,
    this.description,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
    };
  }
}
