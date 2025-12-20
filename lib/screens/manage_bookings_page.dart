import 'package:flutter/material.dart';

import '../services/booking_service.dart';
import '../widgets/AppScaffold.dart';
import '../widgets/State_Booking_Card.dart';

class ManageBookingsPage extends StatefulWidget {
  const ManageBookingsPage({super.key});

  @override
  State<ManageBookingsPage> createState() => _ManageBookingsPageState();
}

class _ManageBookingsPageState extends State<ManageBookingsPage> {
  final BookingService _bookingService = BookingService();

  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  int? _selectedSubjectId;
  bool _onlyToday = false;

  String _statusFilter = 'active'; // الافتراضي يوري الـ Active

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rows = await _bookingService.getAllBookingsWithDetails();
      if (!mounted) return;
      setState(() {
        _bookings = rows;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('load bookings error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _todayName() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
      default:
        return 'Sunday';
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    final todayName = _todayName();

    return _bookings.where((row) {
      // فلترة المادة
      if (_selectedSubjectId != null) {
        final subjectId = row['subject_id'] as int?;
        if (subjectId != _selectedSubjectId) return false;
      }

      // فلترة حجوزات اليوم
      if (_onlyToday) {
        final day = row['day_of_week'] as String?;
        if (day != todayName) return false;
      }

      // فلترة الحالة (Active / Cancelled)
      final rawStatus = (row['booking_status'] ?? '').toString().toLowerCase();
      final isCancelled = rawStatus == 'cancelled';

      if (_statusFilter == 'active' && isCancelled) return false;
      if (_statusFilter == 'cancelled' && !isCancelled) return false;

      return true;
    }).toList();
  }

  int get _todayBookingsCount {
    final todayName = _todayName();
    return _bookings.where((row) => row['day_of_week'] == todayName).length;
  }

  int get _uniqueStudentsCountInFilter {
    final ids = _filteredBookings
        .map((row) => row['student_id'] as int?)
        .where((id) => id != null)
        .toSet();
    return ids.length;
  }

  List<Map<String, dynamic>> get _subjectOptions {
    final Map<int, String> map = {};
    for (final row in _bookings) {
      final id = row['subject_id'] as int?;
      final name = row['subject_name'] as String?;
      if (id != null && name != null) {
        map[id] = name;
      }
    }
    return map.entries.map((e) => {'id': e.key, 'name': e.value}).toList();
  }

  Future<void> _cancelBooking(int bookingId, String studentName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel this booking for "$studentName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _bookingService.cancelBooking(bookingId);
        await _loadBookings();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildStatsRow() {
    final total = _bookings.length;
    final today = _todayBookingsCount;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Bookings',
            value: '$total',
            icon: Icons.event_available_rounded,
            color: const Color(0xFF667eea),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            title: 'Today',
            value: '$today',
            icon: Icons.today_rounded,
            color: const Color(0xFF38B2AC),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildStatusFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Status',
          style: TextStyle(fontSize: 13, color: Color(0xFF718096)),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Active'),
              selected: _statusFilter == 'active',
              onSelected: (_) {
                setState(() => _statusFilter = 'active');
              },
            ),
            ChoiceChip(
              label: const Text('Cancelled'),
              selected: _statusFilter == 'cancelled',
              onSelected: (_) {
                setState(() => _statusFilter = 'cancelled');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final subjects = _subjectOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filters',
          style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // فلترة المادة
            Expanded(
              child: DropdownButtonFormField<int?>(
                value: _selectedSubjectId,
                decoration: InputDecoration(
                  labelText: 'Subject (optional)',
                  labelStyle: const TextStyle(color: Color(0xFF718096)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All subjects'),
                  ),
                  ...subjects.map(
                    (s) => DropdownMenuItem<int?>(
                      value: s['id'] as int,
                      child: Text(s['name'] as String),
                    ),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedSubjectId = val;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            // فلترة اليوم
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today only',
                  style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                ),
                Switch(
                  value: _onlyToday,
                  onChanged: (val) {
                    setState(() {
                      _onlyToday = val;
                    });
                  },
                  activeColor: const Color(0xFF667eea),
                ),
              ],
            ),
          ],
        ),
        if (_selectedSubjectId != null) ...[
          const SizedBox(height: 6),
          Text(
            'Students in selected subject: $_uniqueStudentsCountInFilter',
            style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
          ),
        ],
        _buildStatusFilterChips(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleBookings = _filteredBookings;

    return AppScaffold(
      title: 'Manage Bookings',
      subtitle: 'View and monitor all reservations',
      headerHeight: 180,
      onBack: () => Navigator.pop(context),
      
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF667eea),
              ),
            )
          : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                  _buildFilters(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: visibleBookings.isEmpty
                        ? const Center(
                            child: Text(
                              'No bookings found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF718096),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: visibleBookings.length,
                            itemBuilder: (context, index) {
                              final row = visibleBookings[index];
            
                              final bookingId = row['booking_id'] as int?;
                              final studentName =
                                  (row['student_name'] ?? '').toString();
                              final subjectName =
                                  (row['subject_name'] ?? '').toString();
                              final teacherName =
                                  (row['teacher_name'] ?? '').toString();
                              final dayOfWeek =
                                  (row['day_of_week'] ?? '').toString();
                              final startTime =
                                  (row['start_time'] ?? '').toString();
                              final endTime =
                                  (row['end_time'] ?? '').toString();
            
                              final rawStatus = (row['booking_status'] ?? '')
                                  .toString()
                                  .toLowerCase();
            
                              final isCancelled = rawStatus == 'cancelled';
                              final isActive = !isCancelled;
            
                              final statusLabel =
                                  isCancelled ? 'CANCELLED' : 'ACTIVE';
            
                              final statusColor = isCancelled
                                  ? const Color(0xFFED8936)
                                  : const Color(0xFF48BB78);
            
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF667eea)
                                          .withOpacity(0.05),
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
                                    leading: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF667eea)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF667eea)
                                              .withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.event_note_rounded,
                                        color: Color(0xFF667eea),
                                      ),
                                    ),
                                    title: Text(
                                      studentName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$subjectName • $teacherName\n$dayOfWeek • $startTime - $endTime',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              height: 1.3,
                                              color: Color(0xFF718096),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  statusColor.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              statusLabel,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: statusColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: (bookingId == null || !isActive)
                                        ? null
                                        : IconButton(
                                            onPressed: () => _cancelBooking(
                                              bookingId,
                                              studentName,
                                            ),
                                            icon: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons
                                                    .cancel_schedule_send_rounded,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
          ),
    );
  }
}

