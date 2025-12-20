import '../models/subject.dart';
import '../models/teacher.dart';
import '../services/lesson_service.dart';
import '../services/subject_service.dart';
import '../services/teacher_service.dart';

class ManageLessonsController {
  final LessonService lessonService;
  final SubjectService subjectService;
  final TeacherService teacherService;

  bool isLoading = true;

  List<Subject> subjects = [];
  List<Teacher> teachers = [];
  List<Map<String, dynamic>> lessons = [];

  ManageLessonsController({
    required this.lessonService,
    required this.subjectService,
    required this.teacherService,
  });

  /// تحميل المواد + المدرسين + الدروس أول مرة
  Future<void> loadInitialData() async {
    isLoading = true;
    final loadedSubjects = await subjectService.getAllSubjects();
    final loadedTeachers = await teacherService.getAllTeachers();
    final loadedLessons = await lessonService.getAllLessons();

    subjects = loadedSubjects;
    teachers = loadedTeachers;
    lessons = loadedLessons;
    isLoading = false;
  }

  /// إعادة تحميل الدروس فقط (بعد إضافة / تعديل / حذف)
  Future<void> reloadLessons() async {
    lessons = await lessonService.getAllLessons();
  }

  /// Helper: اسم المدرّس من الـ id
  String teacherNameFor(int teacherId) {
    try {
      return teachers.firstWhere((t) => t.id == teacherId).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  /// Helper: اسم المادة من الـ id
  String subjectNameFor(int subjectId) {
    try {
      return subjects.firstWhere((s) => s.id == subjectId).name;
    } catch (_) {
      return 'Unknown subject';
    }
  }
}
