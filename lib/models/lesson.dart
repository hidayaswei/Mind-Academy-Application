class Lesson {
  final int id;
  final int subjectId;
  final int teacherId;
  final String teacherName;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  Lesson({
    required this.id,
    required this.subjectId,
    required this.teacherId,
    required this.teacherName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as int,
      subjectId: map['subject_id'] as int,
      teacherId: map['teacher_id'] as int,
      teacherName: (map['teacher_name'] as String?) ?? 'Unknown',
      dayOfWeek: map['day_of_week'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
    );
  }
}