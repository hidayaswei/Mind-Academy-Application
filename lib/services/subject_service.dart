import '../database/database_helper.dart';
import '../models/subject.dart';

class SubjectService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// جلب كل المواد
  Future<List<Subject>> getAllSubjects() async {
    final rows = await _db.getAllSubjects();
    return rows.map<Subject>((m) => Subject.fromMap(m)).toList();
  }

  /// إضافة مادة جديدة
  Future<void> addSubject({
    required String name,
    String? description,
  }) async {
    await _db.insertSubject({
      'name': name,
      'description': description,
    });
  }

  /// تعديل مادة موجودة
  Future<void> updateSubject({
    required int id,
    required String name,
    String? description,
  }) async {
    await _db.updateSubject({
      'id': id,
      'name': name,
      'description': description,
    });
  }

  /// حذف مادة
  Future<void> deleteSubject(int id) async {
    final db = await _db.database;
    await db.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
