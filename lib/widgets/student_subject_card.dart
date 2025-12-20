import 'package:flutter/material.dart';
import '../models/subject.dart';

class StudentSubjectCard extends StatelessWidget {
  final Subject subject;
  final int index;
  final VoidCallback onTap;

  const StudentSubjectCard({
    super.key,
    required this.subject,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFF667eea),
      Color(0xFFed64a6),
      Color(0xFF48bb78),
      Color(0xFFed8936),
      Color(0xFF9f7aea),
    ];
    const icons = [
      Icons.calculate_rounded,
      Icons.science_rounded,
      Icons.menu_book_rounded,
      Icons.eco_rounded,
      Icons.history_edu_rounded,
    ];

    final color = colors[index % colors.length];
    final icon = icons[index % icons.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subject.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to view lessons',
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
