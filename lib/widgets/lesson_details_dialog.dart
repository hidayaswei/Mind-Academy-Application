import 'package:flutter/material.dart';

class LessonDetailsDialog extends StatefulWidget {
  final String teacherName;
  final String subjectName;
  final Map<String, dynamic> lesson;
  final bool isInitiallyBooked;
  final Future<void> Function() onBook;
  final Future<void> Function() onCancel;

  const LessonDetailsDialog({
    super.key,
    required this.teacherName,
    required this.subjectName,
    required this.lesson,
    required this.isInitiallyBooked,
    required this.onBook,
    required this.onCancel,
  });

  @override
  State<LessonDetailsDialog> createState() => _LessonDetailsDialogState();
}

class _LessonDetailsDialogState extends State<LessonDetailsDialog> {
  late bool _booked;

  @override
  void initState() {
    super.initState();
    _booked = widget.isInitiallyBooked;
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _booked
                      ? [const Color(0xFFED8936), const Color(0xFFDD6B20)]
                      : [const Color(0xFF667eea), const Color(0xFF5a67d8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _booked
                        ? const Color(0xFFED8936).withOpacity(0.3)
                        : const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              widget.teacherName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subjectName,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Day',
                  value: lesson['day_of_week']?.toString() ?? '',
                ),
                _infoTile(
                  icon: Icons.access_time_rounded,
                  label: 'Time',
                  value:
                      '${lesson['start_time']} - ${lesson['end_time']}',
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (_booked) {
                  await widget.onCancel();
                } else {
                  await widget.onBook();
                }
                if (mounted) {
                  setState(() => _booked = !_booked);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _booked
                    ? const Color(0xFFED8936)
                    : const Color(0xFF667eea),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _booked
                        ? Icons.cancel_rounded
                        : Icons.book_online_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _booked ? 'Cancel Booking' : 'Book This Lesson',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF718096)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF667eea), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }
}
