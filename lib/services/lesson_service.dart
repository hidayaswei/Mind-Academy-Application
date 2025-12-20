import '../database/database_helper.dart';

class LessonService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getAllLessons() async {
    final db = await _db.database;
    final rows = await db.query(
      'lessons',
      orderBy: 'day_of_week, start_time',
    );
    return rows;
  }

  Future<void> addLesson(Map<String, dynamic> data) async {
    await _db.insertLesson(data);
  }

  Future<void> updateLesson(Map<String, dynamic> data) async {
    await _db.updateLesson(data);
  }

  Future<void> deleteLesson(int id) async {
    final db = await _db.database;
    await db.delete(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
