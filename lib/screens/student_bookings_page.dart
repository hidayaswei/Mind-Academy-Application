import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../widgets/AppScaffold.dart';

class StudentBookingsPage extends StatefulWidget {
  final AppUser student;

  const StudentBookingsPage({
    super.key,
    required this.student,
  });

  @override
  State<StudentBookingsPage> createState() => _StudentBookingsPageState();
}

class _StudentBookingsPageState extends State<StudentBookingsPage> {
  final BookingService _bookingService = BookingService();

  bool _isLoading = true;
  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final list =
          await _bookingService.getBookingsByStudent(widget.student.id);
      if (!mounted) return;
      setState(() {
        _bookings = list;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('load bookings error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading bookings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    try {
      await _bookingService.cancelBooking(booking.id!);
      await _loadBookings();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('cancel booking error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _statusColor(Booking booking) {
    if (booking.status.toLowerCase() == 'active') {
      return const Color(0xFF48BB78); // أخضر
    } else {
      return const Color(0xFFED8936); // برتقالي
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'My Bookings',
      subtitle: 'Your lesson reservations',
      headerHeight: 180,
      onBack: () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF667eea),
                ),
              )
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final activeBookings = _bookings
        .where((b) => b.status.toLowerCase() != 'cancelled')
        .toList();

    if (activeBookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'You have no active bookings',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        itemCount: activeBookings.length,
        itemBuilder: (context, index) {
          final booking = activeBookings[index];

          final isActive = booking.status.toLowerCase() != 'cancelled';
          final color = _statusColor(booking);

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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // أيقونة الحجز
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isActive
                            ? [const Color(0xFF667eea), const Color(0xFF5a67d8)]
                            : [const Color(0xFFED8936), const Color(0xFFDD6B20)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isActive
                              ? const Color(0xFF667eea).withOpacity(0.3)
                              : const Color(0xFFED8936).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isActive
                          ? Icons.event_available_rounded
                          : Icons.event_busy_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // بيانات الحجز
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lesson #${booking.lessonId}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ACTIVE',
                          style: TextStyle(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created at: ${booking.createdAt}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // زر إلغاء الحجز
                  TextButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Cancel booking'),
                          content: const Text(
                            'Are you sure you want to cancel this booking?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFED8936),
                              ),
                              child: const Text('Yes, cancel'),
                            ),
                          ],
                        ),
                      );

                      if (ok == true) {
                        await _cancelBooking(booking);
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFED8936),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
