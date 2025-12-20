import 'package:flutter/material.dart';
import '../models/teacher.dart';
import '../services/teacher_service.dart';
import '../widgets/management_page_layout.dart';

class ManageTeacherPage extends StatefulWidget {
  const ManageTeacherPage({super.key});

  @override
  State<ManageTeacherPage> createState() => _ManageTeacherPageState();
}

class _ManageTeacherPageState extends State<ManageTeacherPage> {
  final TeacherService _teacherService = TeacherService();
  late Future<List<Teacher>> _teachersFuture;

  @override
  void initState() {
    super.initState();
    _teachersFuture = _teacherService.getAllTeachers();
  }

  void _refreshTeachers() {
    setState(() {
      _teachersFuture = _teacherService.getAllTeachers();
    });
  }

  Future<void> _showAddOrEditTeacherDialog({Teacher? teacher}) async {
    final nameController = TextEditingController(text: teacher?.name ?? '');
    final phoneController = TextEditingController(text: teacher?.phone ?? '');
    final specController = TextEditingController(text: teacher?.specialization ?? '');
    final formKey = GlobalKey<FormState>();
    final isEdit = teacher != null;

    await ManagementPageLayout.showStyledDialog(
      context,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ManagementPageLayout.dialogHeader(
              icon: isEdit ? Icons.edit_outlined : Icons.person_add_alt_1_rounded,
              color: const Color(0xFF667eea),
              title: isEdit ? 'Edit Teacher' : 'Add Teacher',
              subtitle: isEdit ? 'Update teacher information' : 'Enter teacher information',
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: ManagementPageLayout.fieldDecoration(
                      label: 'Name',
                      icon: Icons.person_outline,
                      focusColor: const Color(0xFF667eea),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter teacher name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: ManagementPageLayout.fieldDecoration(
                      label: 'Phone (optional)',
                      icon: Icons.phone_outlined,
                      focusColor: const Color(0xFF667eea),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: specController,
                    decoration: ManagementPageLayout.fieldDecoration(
                      label: 'Specialization (optional)',
                      icon: Icons.school_outlined,
                      focusColor: const Color(0xFF764ba2),
                    ),
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
                      try {
                        if (isEdit) {
                          final updated = Teacher(
                            id: teacher.id,
                            name: nameController.text,
                            phone: phoneController.text.isEmpty ? null : phoneController.text,
                            specialization: specController.text.isEmpty ? null : specController.text,
                          );
                          await _teacherService.updateTeacher(updated);
                          if (context.mounted) {
                            Navigator.pop(context);
                            _refreshTeachers();
                            ManagementPageLayout.showSuccess(context, 'Teacher updated successfully');
                          }
                        } else {
                          final newTeacher = Teacher(
                            id: null,
                            name: nameController.text,
                            phone: phoneController.text.isEmpty ? null : phoneController.text,
                            specialization: specController.text.isEmpty ? null : specController.text,
                          );
                          await _teacherService.addTeacher(newTeacher);
                          if (context.mounted) {
                            Navigator.pop(context);
                            _refreshTeachers();
                            ManagementPageLayout.showSuccess(context, 'Teacher added successfully');
                          }
                        }
                      } catch (e) {
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

  Future<void> _deleteTeacher(Teacher teacher) async {
    final ok = await ManagementPageLayout.confirmDelete(
      context,
      title: 'Delete Teacher',
      message: 'Are you sure you want to delete "${teacher.name}"?',
    );
    if (!ok) return;

    try {
      await _teacherService.deleteTeacher(teacher.id!);
      _refreshTeachers();
      if (mounted) {
        ManagementPageLayout.showSuccess(context, '"${teacher.name}" deleted successfully');
      }
    } catch (e) {
      if (mounted) ManagementPageLayout.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ManagementPageLayout(
      title: 'Manage Teachers',
      subtitle: 'Add, edit and manage teachers',
      headerHeight: 160,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditTeacherDialog(),
        backgroundColor: const Color(0xFF667eea),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      child: FutureBuilder<List<Teacher>>(
        future: _teachersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ManagementPageLayout.loading();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }

          final teachers = snapshot.data ?? [];
          if (teachers.isEmpty) {
            return ManagementPageLayout.emptyState(
              icon: Icons.people_outline,
              title: 'No Teachers Yet',
              subtitle: 'Tap + to add your first teacher',
            );
          }

          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];

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
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: InkWell(
                    onTap: () => _showAddOrEditTeacherDialog(teacher: teacher),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF667eea).withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(Icons.person_rounded, color: Color(0xFF667eea), size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teacher.name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                if (teacher.specialization != null && teacher.specialization!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      teacher.specialization!,
                                      style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
                                    ),
                                  ),
                                if (teacher.phone != null && teacher.phone!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      teacher.phone!,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFFA0AEC0)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _showAddOrEditTeacherDialog(teacher: teacher),
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
                                onPressed: () => _deleteTeacher(teacher),
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
