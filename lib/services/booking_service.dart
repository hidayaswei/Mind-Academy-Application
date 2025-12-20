import '../database/database_helper.dart';
import '../models/booking.dart';

class BookingService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// جميع حجوزات الطالب
  Future<List<Booking>> getBookingsByStudent(int studentId) async {
    final rows = await _db.getBookingsByStudent(studentId);
    return rows.map((m) => Booking.fromMap(m)).toList();
  }

  /// حجز درس جديد
  Future<void> bookLesson(Booking booking) async {
    final data = booking.toMap()..remove('id'); // ID auto-increment
    await _db.insertBooking(data);
  }

  /// إلغاء حجز (من طرف الطالب أو الأدمن)
  Future<void> cancelBooking(int bookingId) async {
    await _db.cancelBooking(bookingId);
  }

  /// جلب دروس مادة معينة (Map لأن جدول الدروس مش Booking)
  Future<List<Map<String, dynamic>>> getLessonsBySubject(int subjectId) {
    return _db.getLessonsBySubject(subjectId);
  }
 Future<List<Map<String, dynamic>>> getAllBookingsWithDetails() async {
  final db = await _db.database;

  final rows = await db.rawQuery('''
    SELECT 
      b.id          AS booking_id,
      b.student_id,
      b.lesson_id,
      b.status      AS booking_status,
      b.created_at  AS booking_created_at,
      b.cancelled_at AS booking_cancelled_at,

      u.name   AS student_name,
      u.email  AS student_email,
      
      s.id     AS subject_id,
      s.name   AS subject_name,
      
      t.id     AS teacher_id,
      t.name   AS teacher_name,
      
      l.day_of_week,
      l.start_time,
      l.end_time
    FROM bookings b
    JOIN users    u ON u.id = b.student_id
    JOIN lessons  l ON l.id = b.lesson_id
    JOIN subjects s ON s.id = l.subject_id
    JOIN teachers t ON t.id = l.teacher_id
    ORDER BY l.day_of_week, l.start_time
  ''');

  return rows;
}
}
