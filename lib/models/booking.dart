class Booking {
  final int? id;
  final int studentId;
  final int lessonId;
  final String status;      // active / cancelled
  final String createdAt;   
  final String? cancelledAt;

  Booking({
    required this.id,
    required this.studentId,
    required this.lessonId,
    required this.status,
    required this.createdAt,
    this.cancelledAt,
  });

  /// تحويل row من DB إلى موديل
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      lessonId: map['lesson_id'] as int,
      status: map['status'] as String,
      createdAt: map['created_at'] as String,
      cancelledAt: map['cancelled_at'] as String?,
    );
  }

  /// تحويل الموديل إلى map للإدخال في DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'lesson_id': lessonId,
      'status': status,
      'created_at': createdAt,
      'cancelled_at': cancelledAt,
    };
  }
}
