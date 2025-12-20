import 'package:flutter/material.dart';
import 'manage_bookings_page.dart';
import 'manage_subjects_page.dart';
import 'manage_users_page.dart';
import 'admin_settings_page.dart';
import 'manage_lessons_page.dart';
import 'manage_teacher_page.dart';
import 'welcome_page.dart';
import '../models/user.dart';
import '../widgets/AppScaffold.dart';
import '../controllers/state.dart'; // isLoggedIn

class AdminHomePage extends StatelessWidget {
  final AppUser admin;

  const AdminHomePage({super.key, required this.admin});

  void _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFF718096)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF667eea)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      isLoggedIn.value = false;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admin Dashboard',
      subtitle: 'Welcome back, ${admin.name}',
      headerHeight: 225,
      showLogo: true,
      onLogout: () => _confirmLogout(context),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Color(0xFFF8FAFF)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'Management Tools',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            const Text(
              'Select what you want to manage',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildCard(
                    title: 'Manage Subjects',
                    description: 'Add, edit and organize study subjects',
                    icon: Icons.book_rounded,
                    iconColor: const Color(0xFF667eea),
                    gradient: const [Color(0xFF667eea), Color(0xFF5a67d8)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageSubjectsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: 'Manage Users',
                    description: 'Manage students and teachers accounts',
                    icon: Icons.people_rounded,
                    iconColor: const Color(0xFF764ba2),
                    gradient: const [Color(0xFF764ba2), Color(0xFF9f7aea)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManageUsersPage(currentAdmin: admin),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: 'Manage Teachers',
                    description: 'Add, edit and manage teachers',
                    icon: Icons.school_rounded,
                    iconColor: const Color(0xFF3182CE),
                    gradient: const [Color(0xFF4299E1), Color(0xFF3182CE)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageTeacherPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: 'Manage Lessons',
                    description: 'Organize lessons and schedule',
                    icon: Icons.schedule_rounded,
                    iconColor: const Color(0xFFED8936),
                    gradient: const [Color(0xFFED8936), Color(0xFFDD6B20)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageLessonsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: 'Manage Booking',
                    description: 'Manage students Bookings',
                    icon: Icons.library_books,
                    iconColor: const Color.fromARGB(255, 162, 75, 127),
                    gradient: const [
                      Color.fromARGB(255, 162, 75, 127),
                      Color.fromARGB(255, 148, 74, 118),
                    ],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ManageBookingsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: 'System Settings',
                    description: 'Configuration and preferences',
                    icon: Icons.settings_rounded,
                    iconColor: const Color(0xFF48BB78),
                    gradient: const [Color(0xFF48BB78), Color(0xFF38A169)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminSettingsPage(admin: admin),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: iconColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
