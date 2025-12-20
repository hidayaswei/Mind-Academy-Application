// controllers/student_controller.dart
import '../models/subject.dart';
import '../models/teacher.dart';
import '../models/booking.dart';
import '../models/user.dart';

import '../services/subject_service.dart';
import '../services/teacher_service.dart';
import '../services/booking_service.dart';

class StudentController {
  final SubjectService _subjectService;
  final TeacherService _teacherService;
  final BookingService _bookingService;

  StudentController(
    this._subjectService,
    this._teacherService,
    this._bookingService,
  );

  bool isLoading = true;
  List<Subject> subjects = [];
  List<Teacher> teachers = [];
  List<Booking> bookings = [];

  // تحميل البيانات الأساسية
  Future<void> loadInitialData(int studentId) async {
    isLoading = true;
    final s = await _subjectService.getAllSubjects();
    final t = await _teacherService.getAllTeachers();
    final b = await _bookingService.getBookingsByStudent(studentId);

    subjects = s;
    teachers = t;
    bookings = b;
    isLoading = false;
  }

  Future<void> reloadBookings(int studentId) async {
    bookings = await _bookingService.getBookingsByStudent(studentId);
  }

  String teacherNameFor(int? id) {
    if (id == null) return 'Not Assigned';
    try {
      return teachers.firstWhere((t) => t.id == id).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  bool isLessonBooked(int lessonId) {
    return bookings.any(
      (b) => b.lessonId == lessonId && b.status == 'active',
    );
  }

  Future<List<Map<String, dynamic>>> getLessonsBySubject(Subject subject) async {
    
    return await _bookingService.getLessonsBySubject(subject.id);
  }

  Future<void> bookLesson({
    required AppUser student,
    required Map<String, dynamic> lesson,
  }) async {
    final lessonId = lesson['id'] as int?;
    if (lessonId == null) return;

    if (isLessonBooked(lessonId)) {
      
      return;
    }

    final booking = Booking(
      id: null,
      studentId: student.id,
      lessonId: lessonId,
      status: 'active',
      createdAt: DateTime.now().toIso8601String(),
      cancelledAt: null,
    );

    await _bookingService.bookLesson(booking);
    await reloadBookings(student.id);
  }

  Future<bool> hasActiveBookingForLesson(int lessonId) async {
    return isLessonBooked(lessonId);
  }

  Future<void> cancelBookingForLesson({
    required AppUser student,
    required Map<String, dynamic> lesson,
  }) async {
    final lessonId = lesson['id'] as int?;
    if (lessonId == null) return;

    final active = bookings
        .where((b) => b.lessonId == lessonId && b.status == 'active')
        .toList();
    if (active.isEmpty) return;

    await _bookingService.cancelBooking(active.first.id!);
    await reloadBookings(student.id);
  }
}
