import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../services/lesson_service.dart';
import '../services/subject_service.dart';
import '../services/teacher_service.dart';
import '../controllers/manage_lessons_controller.dart';
import '../widgets/management_page_layout.dart';

class ManageLessonsPage extends StatefulWidget {
  const ManageLessonsPage({super.key});

  @override
  State<ManageLessonsPage> createState() => _ManageLessonsPageState();
}

class _ManageLessonsPageState extends State<ManageLessonsPage> {
  late final ManageLessonsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ManageLessonsController(
      lessonService: LessonService(),
      subjectService: SubjectService(),
      teacherService: TeacherService(),
    );
    _loadInitialDataUI();
  }

  Future<void> _loadInitialDataUI() async {
    try {
      await _controller.loadInitialData();
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      if (!mounted) return;
      ManagementPageLayout.showError(context, e);
    } finally {
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _reloadLessonsUI() async {
    try {
      await _controller.reloadLessons();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint('Error reloading lessons: $e');
      if (mounted) ManagementPageLayout.showError(context, e);
    }
  }

  Future<void> _showLessonDialog({Map<String, dynamic>? lesson}) async {
    final formKey = GlobalKey<FormState>();

    Subject? selectedSubject;
    final subjectIdFromLesson = lesson?['subject_id'] as int?;
    if (subjectIdFromLesson != null) {
      try {
        selectedSubject = _controller.subjects.firstWhere((s) => s.id == subjectIdFromLesson);
      } catch (_) {}
    }

    String? selectedDay = lesson?['day_of_week'] as String?;
    int? selectedTeacherId = lesson?['teacher_id'] as int?;
    final startController = TextEditingController(text: lesson?['start_time'] as String? ?? '');
    final endController = TextEditingController(text: lesson?['end_time'] as String? ?? '');

    Future<void> pickTime(TextEditingController controller) async {
      final now = TimeOfDay.now();
      final picked = await showTimePicker(
        context: context,
        initialTime: now,
      );
      if (picked != null) {
        controller.text = picked.format(context);
      }
    }

    final isEdit = lesson != null;

    await ManagementPageLayout.showStyledDialog(
      context,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ManagementPageLayout.dialogHeader(
              icon: Icons.schedule_rounded,
              color: const Color(0xFF667eea),
              title: isEdit ? 'Edit Lesson' : 'Add New Lesson',
              subtitle: 'Choose subject, teacher and time',
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<Subject>(
                    value: selectedSubject,
                    decoration: ManagementPageLayout.fieldDecoration(
                      label: 'Subject',
                      icon: Icons.book_outlined,
                      focusColor: const Color(0xFF667eea),
                    ),
                    items: _controller.subjects
                        .map((s) => DropdownMenuItem<Subject>(
                              value: s,
                              child: Text(s.name),
                            ))
                        .toList(),
                    onChanged: (value) => selectedSubject = value,
                    validator: (value) => value == null ? 'Please select a subject' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    value: selectedTeacherId,
                    decoration: ManagementPageLayout.fieldDecoration(
                      label: 'Teacher',
                      icon: Icons.person_outline,
                      focusColor: const Color(0xFF667eea),
                    ),
                    items: _controller.teachers
                        .map((t) => DropdownMenuItem<int>(
                              value: t.id,
                              child: Text(t.name),
                            ))
                        .toList(),
                    onChanged: (val) => selectedTeacherId = val,
                    validator: (value) => value == null ? 'Please select a teacher' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    decoration: ManagementPageLayout.fieldDecoration(
                      label: 'Day of Week',
                      icon: Icons.calendar_today_outlined,
                      focusColor: const Color(0xFF667eea),
                    ),
                    items: const [
                      'Saturday',
                      'Sunday',
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                    ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => selectedDay = val,
                    validator: (value) => (value == null || value.isEmpty) ? 'Please select day' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: startController,
                    readOnly: true,
                    onTap: () => pickTime(startController),
                    decoration: ManagementPageLayout.fieldDecoration(
                      label: 'Start Time',
                      icon: Icons.access_time,
                      focusColor: const Color(0xFF764ba2),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please choose start time' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: endController,
                    readOnly: true,
                    onTap: () => pickTime(endController),
                    decoration: ManagementPageLayout.fieldDecoration(
                      label: 'End Time',
                      icon: Icons.timelapse,
                      focusColor: const Color(0xFF764ba2),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please choose end time' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: ManagementPageLayout.cancelButton(context)),
                const SizedBox(width: 12),
                Expanded(
                  child: ManagementPageLayout.primaryButton(
                    text: isEdit ? 'Update' : 'Save',
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final data = {
                        'subject_id': selectedSubject!.id,
                        'teacher_id': selectedTeacherId,
                        'day_of_week': selectedDay,
                        'start_time': startController.text,
                        'end_time': endController.text,
                      };

                      try {
                        if (!isEdit) {
                          await _controller.lessonService.addLesson(data);
                        } else {
                          data['id'] = lesson['id'];
                          await _controller.lessonService.updateLesson(data);
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          await _reloadLessonsUI();
                          ManagementPageLayout.showSuccess(
                            context,
                            isEdit ? 'Lesson updated successfully' : 'Lesson added successfully',
                          );
                        }
                      } catch (e) {
                        debugPrint('Error saving lesson: $e');
                        if (context.mounted) ManagementPageLayout.showError(context, e);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteLesson(int id) async {
    final ok = await ManagementPageLayout.confirmDelete(
      context,
      title: 'Delete Lesson',
      message: 'Are you sure you want to delete this lesson?',
    );
    if (!ok) return;

    try {
      await _controller.lessonService.deleteLesson(id);
      await _reloadLessonsUI();
      if (mounted) ManagementPageLayout.showSuccess(context, 'Lesson deleted successfully');
    } catch (e) {
      if (mounted) ManagementPageLayout.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ManagementPageLayout(
      title: 'Manage Lessons',
      subtitle: 'Schedule and organize classes',
      headerHeight: 170,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller.subjects.isEmpty) {
            ManagementPageLayout.showInfo(context, 'Add subjects first');
            return;
          }
          if (_controller.teachers.isEmpty) {
            ManagementPageLayout.showInfo(context, 'Add teachers first');
            return;
          }
          _showLessonDialog();
        },
        backgroundColor: const Color(0xFF667eea),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      child: _controller.isLoading
          ? ManagementPageLayout.loading()
          : _controller.lessons.isEmpty
              ? const Center(
                  child: Text(
                    'No lessons yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
                  ),
                )
              : ListView.builder(
                  itemCount: _controller.lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = _controller.lessons[index];
                    final teacherId = lesson['teacher_id'] as int?;
                    final subjectId = lesson['subject_id'] as int?;
                    final teacherName = teacherId == null ? 'Unknown' : _controller.teacherNameFor(teacherId);
                    final subjectName = subjectId == null ? 'Unknown subject' : _controller.subjectNameFor(subjectId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF667eea).withOpacity(0.2), width: 1.5),
                            ),
                            child: const Icon(Icons.schedule_rounded, color: Color(0xFF667eea)),
                          ),
                          title: Text(
                            teacherName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$subjectName • ${lesson['day_of_week']} • ${lesson['start_time']} - ${lesson['end_time']}',
                              style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _showLessonDialog(lesson: lesson),
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF667eea).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.edit_outlined, color: Color(0xFF667eea), size: 20),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () => _deleteLesson(lesson['id'] as int),
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
