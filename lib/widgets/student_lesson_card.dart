import 'package:flutter/material.dart';

class StudentLessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final String teacherName;
  final bool isBooked;
  final VoidCallback onTap;
  final VoidCallback onActionPressed;

  const StudentLessonCard({
    super.key,
    required this.lesson,
    required this.teacherName,
    required this.isBooked,
    required this.onTap,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isBooked
                          ? [const Color(0xFFED8936), const Color(0xFFDD6B20)]
                          : [const Color(0xFF667eea), const Color(0xFF5a67d8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isBooked
                            ? const Color(0xFFED8936).withOpacity(0.3)
                            : const Color(0xFF667eea).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isBooked
                        ? Icons.event_available_rounded
                        : Icons.schedule_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              teacherName,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: isBooked
                                    ? const Color(0xFFED8936)
                                    : const Color(0xFF667eea),
                              ),
                            ),
                          ),
                          if (isBooked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFED8936)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'BOOKED',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFED8936),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${lesson['day_of_week']} • ${lesson['start_time']} - ${lesson['end_time']}',
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
                ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBooked
                        ? const Color(0xFFED8936)
                        : const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    isBooked ? 'Cancel' : 'Book',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
