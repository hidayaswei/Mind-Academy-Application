import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/subject.dart';

import '../controllers/student_controller.dart';

import '../services/subject_service.dart';
import '../services/teacher_service.dart';
import '../services/booking_service.dart';

import '../widgets/AppScaffold.dart';
import '../widgets/student_subject_card.dart';
import '../widgets/student_lesson_card.dart';
import '../widgets/lesson_details_dialog.dart';
import '../widgets/primary_button.dart';

import '../controllers/state.dart';
import 'student_bookings_page.dart';
import 'welcome_page.dart';

class StudentHomePage extends StatefulWidget {
  final AppUser student;

  const StudentHomePage({
    super.key,
    required this.student,
  });

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  late final StudentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StudentController(
      SubjectService(),
      TeacherService(),
      BookingService(),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _controller.loadInitialData(widget.student.id);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint('loadData error: $e');
      if (!mounted) return;
      setState(() {
        _controller.isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
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
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<bool> _handleSystemBack() async {
    final ok = await _confirmLogout(context);
    if (ok) {
      isLoggedIn.value = false;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
        (route) => false,
      );
    }
    return false;
  }

  Future<void> _showSubjectLessons(
    BuildContext context,
    Subject subject,
  ) async {
    try {
      final lessons = await _controller.getLessonsBySubject(subject);

      if (!mounted) return;

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 500,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      '${subject.name} Lessons',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select a lesson to book',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: lessons.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No lessons available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF718096),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: lessons.length,
                              itemBuilder: (context, index) {
                                final lesson = lessons[index];
                                final id = lesson['id'] as int?;
                                final isBooked = id != null
                                    ? _controller.isLessonBooked(id)
                                    : false;
                                final teacherName = _controller.teacherNameFor(
                                  lesson['teacher_id'] as int?,
                                );

                                return StudentLessonCard(
                                  lesson: lesson,
                                  teacherName: teacherName,
                                  isBooked: isBooked,
                                  onActionPressed: () async {
                                    try {
                                      if (isBooked) {
                                        await _controller
                                            .cancelBookingForLesson(
                                          student: widget.student,
                                          lesson: lesson,
                                        );
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Cancelled successfully',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        await _controller.bookLesson(
                                          student: widget.student,
                                          lesson: lesson,
                                        );
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Booking successful!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                      setState(() {});
                                      setModalState(() {});
                                    } catch (e) {
                                      debugPrint('booking error: $e');
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Failed: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => LessonDetailsDialog(
                                        teacherName: teacherName,
                                        subjectName: subject.name,
                                        lesson: lesson,
                                        isInitiallyBooked: isBooked,
                                        onBook: () async {
                                          await _controller.bookLesson(
                                            student: widget.student,
                                            lesson: lesson,
                                          );
                                          setState(() {});
                                          setModalState(() {});
                                        },
                                        onCancel: () async {
                                          await _controller
                                              .cancelBookingForLesson(
                                            student: widget.student,
                                            lesson: lesson,
                                          );
                                          setState(() {});
                                          setModalState(() {});
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } catch (e) {
      debugPrint('showSubjectLessons error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleSystemBack,
      child: AppScaffold(
        title: 'Hello ${widget.student.name}',
        subtitle: 'Book your lessons easily',
        headerHeight: 225,
        showLogo: true,
        onLogout: () async {
          final ok = await _confirmLogout(context);
          if (ok) {
            isLoggedIn.value = false;
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomePage()),
              (route) => false,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _controller.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF667eea),
                  ),
                )
              : _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Subjects',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap to view lessons',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF718096),
          ),
        ),
        const SizedBox(height: 16),

        // زر My Bookings
        PrimaryButton(
          text: 'My Bookings',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentBookingsPage(
                  student: widget.student,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // المواد
        Expanded(
          child: _controller.subjects.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_rounded,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No subjects available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _controller.subjects.length,
                  itemBuilder: (context, i) => StudentSubjectCard(
                    subject: _controller.subjects[i],
                    index: i,
                    onTap: () => _showSubjectLessons(
                      context,
                      _controller.subjects[i],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
