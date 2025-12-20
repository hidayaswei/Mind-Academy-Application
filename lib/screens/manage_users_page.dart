import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/management_page_layout.dart';

class ManageUsersPage extends StatefulWidget {
  final AppUser currentAdmin;

  const ManageUsersPage({super.key, required this.currentAdmin});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final UserService _userService = UserService();

  List<AppUser> _users = [];
  bool _isLoading = true;
  String? _roleFilter; // null = All

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final users = await _userService.getUsers(role: _roleFilter);
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('load users error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ManagementPageLayout.showError(context, e);
    }
  }

  void _setFilter(String? role) {
    setState(() => _roleFilter = role);
    _loadUsers();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFED8936);
      case 'student':
      default:
        return const Color(0xFF48BB78);
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'student':
      default:
        return 'Student';
    }
  }

  bool _canShowDelete(AppUser target) {
    final current = widget.currentAdmin;
    final isSuperAdmin = current.role == 'admin' && current.id == 1;

    if (target.id == 1) return false; // main admin
    if (isSuperAdmin) {
      return target.id != current.id;
    }
    if (current.role == 'admin') {
      return target.role != 'admin';
    }
    return false;
  }

  Future<void> _deleteUser(AppUser user) async {
    
    if (user.id == widget.currentAdmin.id) {
      ManagementPageLayout.showInfo(context, 'You cannot delete your own account');
      return;
    }
    if (user.id == 1) {
      ManagementPageLayout.showInfo(context, 'You cannot delete the main admin');
      return;
    }

    final ok = await ManagementPageLayout.confirmDelete(
      context,
      title: 'Delete User',
      message: 'Are you sure you want to delete "${user.name}"?',
    );

    if (!ok) return;

    try {
      await _userService.deleteUser(user.id);
      await _loadUsers();

      if (mounted) {
        ManagementPageLayout.showSuccess(context, '"${user.name}" deleted');
      }
    } catch (e) {
      if (mounted) ManagementPageLayout.showError(context, e);
    }
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: _roleFilter == null,
          onSelected: (_) => _setFilter(null),
        ),
        ChoiceChip(
          label: const Text('Students'),
          selected: _roleFilter == 'student',
          onSelected: (_) => _setFilter('student'),
        ),
        ChoiceChip(
          label: const Text('Admins'),
          selected: _roleFilter == 'admin',
          onSelected: (_) => _setFilter('admin'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManagementPageLayout(
      title: 'Manage Users',
      subtitle: 'Students and Admins',
      headerHeight: 190,
      child: _isLoading
          ? ManagementPageLayout.loading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by role',
                  style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                ),
                const SizedBox(height: 8),
                _buildFilterChips(),
                const SizedBox(height: 16),
                Expanded(
                  child: _users.isEmpty
                      ? ManagementPageLayout.emptyState(
                          icon: Icons.people_outline,
                          title: 'No users found',
                          subtitle: 'Try changing the filter',
                        )
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            final roleColor = _roleColor(user.role);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: roleColor.withOpacity(0.07),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  leading: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: roleColor.withOpacity(0.15),
                                    child: Text(
                                      user.name.isNotEmpty
                                          ? user.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: roleColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      Text(
                                        user.email,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF718096),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: roleColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          _roleLabel(user.role),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: roleColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: _canShowDelete(user)
                                      ? IconButton(
                                          onPressed: () => _deleteUser(user),
                                          icon: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
