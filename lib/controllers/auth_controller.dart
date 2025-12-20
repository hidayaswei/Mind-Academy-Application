import '../models/user.dart';
import '../services/user_service.dart';

class AuthController {
  final UserService _userService = UserService();

  Future<AppUser?> login(String email, String password) {
    return _userService.getUserByEmailAndPassword(email, password);
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    String role = 'student',
    String? phone,
  }) async {
    final user = AppUser(
      id: 0, 
      name: name,
      email: email,
      role: role,
    );

    final insertedId = await _userService.createUser(
      user: user,
      password: password,
      phone: phone,
    );

    return insertedId > 0;
  }

  Future<bool> resetPassword(String email, String newPassword) {
    return _userService.resetPasswordByEmail(email, newPassword);
  }
}
