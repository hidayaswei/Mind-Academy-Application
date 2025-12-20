import '../database/database_helper.dart';
import '../models/user.dart';

class UserService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<AppUser?> getUserByEmailAndPassword(
    String email,
    String password,
  ) async {
    final userMap = await _db.getUserByEmailAndPassword(email, password);
    if (userMap == null) return null;
    return AppUser.fromMap(userMap);
  }

  Future<int> createUser({
    required AppUser user,
    required String password,
    String? phone,
  }) async {
    final row = user.toMapForInsert(
      password: password,
      phone: phone,
    );
    return _db.insertUser(row);
  }

  Future<List<AppUser>> getUsers({String? role}) async {
    final rows = await _db.getUsers(role);
    return rows.map((row) => AppUser.fromMap(row)).toList();
  }

  Future<bool> resetPasswordByEmail(String email, String newPassword) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (rows.isEmpty) {
      return false;
    }

    final userId = rows.first['id'] as int;
    await _db.updateUserPassword(userId, newPassword);
    return true;
  }

  
  Future<void> deleteUser(int id) async {
    await _db.deleteUser(id);
  }
}
