import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../services/subject_service.dart';
import '../widgets/management_page_layout.dart';

class ManageSubjectsPage extends StatefulWidget {
  const ManageSubjectsPage({super.key});

  @override
  State<ManageSubjectsPage> createState() => _ManageSubjectsPageState();
}

class _ManageSubjectsPageState extends State<ManageSubjectsPage> {
  final SubjectService _subjectService = SubjectService();
  late Future<List<Subject>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = _subjectService.getAllSubjects();
  }

  void _refreshSubjects() {
    setState(() {
      _subjectsFuture = _subjectService.getAllSubjects();
    });
  }

  Future<void> _showAddOrEditSubjectDialog({Subject? subject}) async {
    final nameController = TextEditingController(text: subject?.name ?? '');
    final descController = TextEditingController(text: subject?.description ?? '');
    final formKey = GlobalKey<FormState>();
    final isEdit = subject != null;

    await ManagementPageLayout.showStyledDialog(
      context,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ManagementPageLayout.dialogHeader(
              icon: isEdit ? Icons.edit_outlined : Icons.add_circle_outline,
              color: isEdit ? const Color(0xFF764ba2) : const Color(0xFF667eea),
              title: isEdit ? 'Edit Subject' : 'Add New Subject',
              subtitle: isEdit ? 'Update subject details' : 'Enter subject details',
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: ManagementPageLayout.fieldDecoration(
                      label: 'Subject Name',
                      icon: Icons.book_outlined,
                      focusColor: const Color(0xFF667eea),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter subject name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: ManagementPageLayout.fieldDecoration(
                      label: 'Description (Optional)',
                      icon: Icons.description_outlined,
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
                    color: isEdit ? const Color(0xFF764ba2) : const Color(0xFF667eea),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      try {
                        if (isEdit) {
                          await _subjectService.updateSubject(
                            id: subject.id,
                            name: nameController.text,
                            description: descController.text.isEmpty ? null : descController.text,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            _refreshSubjects();
                            ManagementPageLayout.showSuccess(context, 'Subject updated successfully');
                          }
                        } else {
                          await _subjectService.addSubject(
                            name: nameController.text,
                            description: descController.text.isEmpty ? null : descController.text,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            _refreshSubjects();
                            ManagementPageLayout.showSuccess(context, 'Subject added successfully');
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

  Future<void> _deleteSubject(int id, String name) async {
    final ok = await ManagementPageLayout.confirmDelete(
      context,
      title: 'Delete Subject',
      message: 'Are you sure you want to delete "$name"?',
    );
    if (!ok) return;

    try {
      await _subjectService.deleteSubject(id);
      _refreshSubjects();
      if (mounted) {
        ManagementPageLayout.showSuccess(context, '"$name" deleted successfully');
      }
    } catch (e) {
      if (mounted) ManagementPageLayout.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ManagementPageLayout(
      title: 'Manage Subjects',
      subtitle: 'All courses and materials',
      headerHeight: 160,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditSubjectDialog(),
        backgroundColor: const Color(0xFF667eea),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      child: FutureBuilder<List<Subject>>(
        future: _subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ManagementPageLayout.loading();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final subjects = snapshot.data ?? [];
          if (subjects.isEmpty) {
            return ManagementPageLayout.emptyState(
              icon: Icons.book_outlined,
              title: 'No Subjects Yet',
              subtitle: 'Tap + to add your first subject',
            );
          }

          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];

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
                    onTap: () => _showAddOrEditSubjectDialog(subject: subject),
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
                            child: const Icon(Icons.book_rounded, color: Color(0xFF667eea), size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject.name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                if (subject.description != null && subject.description!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subject.description!,
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _showAddOrEditSubjectDialog(subject: subject),
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
                                onPressed: () => _deleteSubject(subject.id, subject.name),
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
