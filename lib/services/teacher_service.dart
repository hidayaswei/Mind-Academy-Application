import '../database/database_helper.dart';
import '../models/teacher.dart';

class TeacherService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Teacher>> getAllTeachers() async {
    final rows = await _db.getAllTeachers();
    return rows.map<Teacher>((m) => Teacher.fromMap(m)).toList();
  }

  Future<void> addTeacher(Teacher teacher) async {
    await _db.insertTeacher(teacher.toMap()..remove('id'));
  }

  Future<void> updateTeacher(Teacher teacher) async {
    await _db.updateTeacher(teacher.toMap());
  }

  Future<void> deleteTeacher(int id) async {
    await _db.deleteTeacher(id);
  }
}
