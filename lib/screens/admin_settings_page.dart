import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/admin_settings_service.dart';
import '../widgets/AppScaffold.dart';
import '../widgets/app_text_field.dart'; 

class AdminSettingsPage extends StatefulWidget {
  final AppUser admin;

  const AdminSettingsPage({super.key, required this.admin});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final AdminSettingsService _settingsService = AdminSettingsService();

  // Profile form
  final _profileFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  // Password form
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // New admin form
  final _newAdminFormKey = GlobalKey<FormState>();
  final _newAdminNameController = TextEditingController();
  final _newAdminEmailController = TextEditingController();
  final _newAdminPasswordController = TextEditingController();
  final _newAdminConfirmPasswordController = TextEditingController();

  bool _isUpdatingProfile = false;
  bool _isChangingPassword = false;
  bool _isCreatingAdmin = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.admin.name);
    _emailController = TextEditingController(text: widget.admin.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();

    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    _newAdminNameController.dispose();
    _newAdminEmailController.dispose();
    _newAdminPasswordController.dispose();
    _newAdminConfirmPasswordController.dispose();

    super.dispose();
  }

  void _showSnack(String msg, {Color color = const Color(0xFF667eea)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() => _isUpdatingProfile = true);

    try {
      await _settingsService.updateProfile(
        admin: widget.admin,
        name: _nameController.text,
        email: _emailController.text,
      );

      _showSnack('Profile updated successfully ✅', color: Colors.green);
    } catch (e) {
      _showSnack('Error updating profile: $e', color: Colors.red);
    } finally {
      setState(() => _isUpdatingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnack('Passwords do not match', color: Colors.red);
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnack('New password must be at least 6 characters', color: Colors.red);
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final ok = await _settingsService.changePassword(
        admin: widget.admin,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!ok) {
        _showSnack('Current password incorrect ❌', color: Colors.red);
      } else {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        _showSnack('Password changed successfully 🔐', color: Colors.green);
      }
    } catch (e) {
      _showSnack('Error changing password: $e', color: Colors.red);
    } finally {
      setState(() => _isChangingPassword = false);
    }
  }

  Future<void> _createNewAdmin() async {
    if (!_newAdminFormKey.currentState!.validate()) return;

    if (_newAdminPasswordController.text !=
        _newAdminConfirmPasswordController.text) {
      _showSnack('Passwords do not match', color: Colors.red);
      return;
    }

    if (_newAdminPasswordController.text.length < 6) {
      _showSnack('Password must be at least 6 characters', color: Colors.red);
      return;
    }

    setState(() => _isCreatingAdmin = true);

    try {
      await _settingsService.createNewAdmin(
        name: _newAdminNameController.text,
        email: _newAdminEmailController.text,
        password: _newAdminPasswordController.text,
      );

      _newAdminNameController.clear();
      _newAdminEmailController.clear();
      _newAdminPasswordController.clear();
      _newAdminConfirmPasswordController.clear();

      _showSnack('New admin created successfully 👑', color: Colors.green);
    } catch (e) {
      _showSnack('Error creating admin: $e', color: Colors.red);
    } finally {
      setState(() => _isCreatingAdmin = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'System Settings',
      subtitle: 'Manage your admin account',
      headerHeight: 200,
      onBack: () => Navigator.pop(context),
      bottomText: widget.admin.name,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSectionTitle('Admin Account'),
            const SizedBox(height: 8),
            _buildProfileCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Security'),
            const SizedBox(height: 8),
            _buildPasswordCard(),
            const SizedBox(height: 24),
            if (widget.admin.id == 1) ...[
              _buildSectionTitle('Admins Management'),
              const SizedBox(height: 8),
              _buildNewAdminCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withOpacity(0.12)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _profileFormKey,
          child: Column(
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter name';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email';
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUpdatingProfile ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUpdatingProfile
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withOpacity(0.12)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _passwordFormKey,
          child: Column(
            children: [
              AppTextField(
                controller: _currentPasswordController,
                label: 'Current Password',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter current password';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _newPasswordController,
                label: 'New Password',
                icon: Icons.lock_reset_outlined,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter new password';
                  if (value.length < 6) return 'At least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Confirm password';
                  if (value != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChangingPassword ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF764ba2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isChangingPassword
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Change Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewAdminCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withOpacity(0.12)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _newAdminFormKey,
          child: Column(
            children: [
              AppTextField(
                controller: _newAdminNameController,
                label: 'Admin Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter admin name';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _newAdminEmailController,
                label: 'Admin Email',
                icon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email';
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _newAdminPasswordController,
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter password';
                  if (value.length < 6) return 'At least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _newAdminConfirmPasswordController,
                label: 'Confirm Password',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Confirm password';
                  if (value != _newAdminPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreatingAdmin ? null : _createNewAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5a67d8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isCreatingAdmin
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create New Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
