import '../database/database_helper.dart';
import '../models/user.dart';

class AdminSettingsService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// تحديث بيانات البروفايل متاع الأدمن
  Future<void> updateProfile({
    required AppUser admin,
    required String name,
    required String email,
  }) async {
    await _db.updateUser({
      'id': admin.id,
      'name': name.trim(),
      'email': email.trim(),
      'role': admin.role, 
    });
  }

  /// تغيير كلمة السر، ترجع true لو الباسورد الحالي صحيح
  Future<bool> changePassword({
    required AppUser admin,
    required String currentPassword,
    required String newPassword,
  }) async {
    final userRow = await _db.getUserByEmailAndPassword(
      admin.email,
      currentPassword,
    );

    if (userRow == null) {
      // الباسورد الحالي غلط
      return false;
    }

    await _db.updateUserPassword(admin.id, newPassword);
    return true;
  }

  /// إنشاء أدمن جديد
  Future<void> createNewAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    await _db.insertUser({
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'role': 'admin',
    });
  }
}
