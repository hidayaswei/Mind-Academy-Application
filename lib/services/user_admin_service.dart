import '../database/database_helper.dart';
import '../models/user.dart';

class UserAdminService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<AppUser>> getUsers(String? roleFilter) async {
    final rows = await _db.getUsers(roleFilter);
    return rows.map<AppUser>((m) => AppUser.fromMap(m)).toList();
  }

  Future<void> updateUserRole({
    required AppUser user,
    required String newRole,
  }) async {
    await _db.updateUser({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': newRole,
    });
  }

  Future<void> deleteUser(int id) async {
    final db = await _db.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
