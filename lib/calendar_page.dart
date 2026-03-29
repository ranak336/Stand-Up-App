import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'booking_widgets.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime currentMonth =
  DateTime(DateTime.now().year, DateTime.now().month, 1);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DateTime> _daysInMonth(DateTime month) {
    final last = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      last.day,
          (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  bool _isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _monthTitle(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _calendarStream() {
    final monthStart = DateTime(currentMonth.year, currentMonth.month, 1);
    final monthEnd = DateTime(currentMonth.year, currentMonth.month + 1, 1);

    return _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'confirmed')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .where('date', isLessThan: Timestamp.fromDate(monthEnd))
        .orderBy('date')
        .snapshots();
  }

  Future<void> _deleteBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('bookings').doc(bookingId).delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking deleted successfully')),
      );
    }
  }

  Future<bool> _isDateBookedByAnother(
      DateTime date,
      String currentBookingId,
      ) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final query = await _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'confirmed')
        .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
        .get();

    for (final doc in query.docs) {
      if (doc.id != currentBookingId) {
        return true;
      }
    }
    return false;
  }

  List<DateTime> _availableTuesdaysForMonth(
      DateTime month,
      List<DateTime> bookedDates,
      DateTime currentBookingDate,
      ) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = <DateTime>[];

    for (
    DateTime day = first;
    !day.isAfter(last);
    day = day.add(const Duration(days: 1))
    ) {
      final dateOnly = DateTime(day.year, day.month, day.day);
      final isTuesday = dateOnly.weekday == DateTime.tuesday;
      final isCurrentBookingDate = _isSameDate(dateOnly, currentBookingDate);
      final isBooked = bookedDates.any((d) => _isSameDate(d, dateOnly));

      if (isTuesday &&
          (!dateOnly.isBefore(today)) &&
          (!isBooked || isCurrentBookingDate)) {
        result.add(dateOnly);
      }
    }

    return result;
  }

  Future<void> _showEditBookingDialog(
      String bookingId,
      Map<String, dynamic> data,
      List<DateTime> bookedDates,
      ) async {
    final currentDate = (data['date'] as Timestamp).toDate();
    final selectedDate =
    DateTime(currentDate.year, currentDate.month, currentDate.day);

    final titleController =
    TextEditingController(text: (data['topicTitle'] ?? '').toString());
    final backupController =
    TextEditingController(text: (data['backupPerson'] ?? '').toString());

    final groupMembersList =
    ((data['groupMembers'] ?? []) as List).map((e) => e.toString()).toList();
    final groupMembersController =
    TextEditingController(text: groupMembersList.join(', '));

    final visibility = (data['visibility'] ?? 'Public').toString();

    final availableDates =
    _availableTuesdaysForMonth(currentMonth, bookedDates, selectedDate);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        DateTime tempDate = selectedDate;
        String tempVisibility = visibility;

        return StatefulBuilder(
          builder: (builderContext, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Booking'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<DateTime>(
                      value: availableDates.any((d) => _isSameDate(d, tempDate))
                          ? availableDates.firstWhere(
                            (d) => _isSameDate(d, tempDate),
                      )
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      items: availableDates.map((date) {
                        return DropdownMenuItem<DateTime>(
                          value: date,
                          child: Text(
                            DateFormat('EEEE, MMM d, yyyy').format(date),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            tempDate = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Topic Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tempVisibility,
                      decoration: const InputDecoration(
                        labelText: 'Visibility',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Public',
                          child: Text('Public'),
                        ),
                        DropdownMenuItem(
                          value: 'Private',
                          child: Text('Private'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            tempVisibility = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: backupController,
                      decoration: const InputDecoration(
                        labelText: 'Backup Person',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if ((data['sessionType'] ?? '') == 'group')
                      TextField(
                        controller: groupMembersController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Group Members (comma separated)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGreen,
                  ),
                  onPressed: () async {
                    final dateOnly =
                    DateTime(tempDate.year, tempDate.month, tempDate.day);

                    if (dateOnly.weekday != DateTime.tuesday) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Only Tuesday can be booked'),
                        ),
                      );
                      return;
                    }

                    if (_isPast(dateOnly)) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You cannot select a past date'),
                        ),
                      );
                      return;
                    }

                    final bookedByAnother =
                    await _isDateBookedByAnother(dateOnly, bookingId);

                    if (bookedByAnother) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This date is already booked'),
                        ),
                      );
                      return;
                    }

                    final updatedGroupMembers = groupMembersController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    await _firestore.collection('bookings').doc(bookingId).update({
                      'date': Timestamp.fromDate(dateOnly),
                      'topicTitle': titleController.text.trim(),
                      'visibility': tempVisibility,
                      'backupPerson': backupController.text.trim(),
                      'groupMembers': updatedGroupMembers,
                    });

                    if (!mounted) return;

                    Navigator.of(dialogContext).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking updated successfully'),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    backupController.dispose();
    groupMembersController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(currentMonth);
    final currentUserId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: kLightBg,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'View scheduled sessions',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _calendarStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Error loading calendar:\n${snapshot.error}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          final bookings = snapshot.data?.docs ?? [];
          final bookedDates = <DateTime>[];

          for (final doc in bookings) {
            final data = doc.data();
            final ts = data['date'] as Timestamp;
            final dt = ts.toDate();
            bookedDates.add(DateTime(dt.year, dt.month, dt.day));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            currentMonth = DateTime(
                              currentMonth.year,
                              currentMonth.month - 1,
                              1,
                            );
                          });
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _monthTitle(currentMonth),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kDarkText,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            currentMonth = DateTime(
                              currentMonth.year,
                              currentMonth.month + 1,
                              1,
                            );
                          });
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _LegendItem(color: kBookedGreen, text: 'Booked'),
                      _LegendItem(
                        color: kAvailableGreen,
                        text: 'Available Tuesday',
                      ),
                      _LegendItem(
                        borderColor: kPrimaryGreen,
                        text: 'Today',
                        isOutline: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _WeekText('Sun'),
                          _WeekText('Mon'),
                          _WeekText('Tue'),
                          _WeekText('Wed'),
                          _WeekText('Thu'),
                          _WeekText('Fri'),
                          _WeekText('Sat'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: days.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          final day = days[index];
                          final isTuesday = day.weekday == DateTime.tuesday;
                          final isBooked =
                          bookedDates.any((d) => _isSameDate(d, day));
                          final today = DateTime.now();
                          final isToday = _isSameDate(
                            day,
                            DateTime(today.year, today.month, today.day),
                          );

                          Color bg = Colors.grey.shade100;
                          Color textColor = kDarkText;
                          Border? border;

                          if (isTuesday && !_isPast(day)) {
                            bg = isBooked ? kBookedGreen : kAvailableGreen;
                            textColor = isBooked ? Colors.white : kDarkText;
                          }

                          if (isToday) {
                            border = Border.all(color: kPrimaryGreen, width: 2);
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(14),
                              border: border,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sessions in ${DateFormat('MMMM').format(currentMonth)}',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: kDarkText,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                if (bookings.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'No bookings in this month',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                ...bookings.map((doc) {
                  final data = doc.data();
                  final date = (data['date'] as Timestamp).toDate();
                  final bookingId = doc.id;
                  final isOwner = currentUserId != null &&
                      data['userId'] != null &&
                      data['userId'].toString() == currentUserId;

                  final groupMembers = ((data['groupMembers'] ?? []) as List)
                      .map((e) => e.toString())
                      .toList();

                  final topicTitle = data['topicTitle'] == null ||
                      data['topicTitle'].toString().trim().isEmpty
                      ? (data['topic'] ?? '').toString()
                      : data['topicTitle'].toString();

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topicTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kDarkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['userName']?.toString() ?? 'User',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('EEEE, MMMM d, y').format(date),
                          style: const TextStyle(
                            fontSize: 16,
                            color: kDarkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${data['sessionType']} • ${data['visibility']}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                        if ((data['sessionType'] ?? '') == 'group' &&
                            groupMembers.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          const Text(
                            'Group Members:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kDarkText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...groupMembers.map(
                                (member) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(member)),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (isOwner) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _showEditBookingDialog(
                                      bookingId,
                                      data,
                                      bookedDates,
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: kPrimaryGreen,
                                    side: const BorderSide(color: kPrimaryGreen),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _deleteBooking(bookingId),
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WeekText extends StatelessWidget {
  final String text;

  const _WeekText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color? color;
  final Color? borderColor;
  final String text;
  final bool isOutline;

  const _LegendItem({
    required this.text,
    this.color,
    this.borderColor,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isOutline ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(4),
            border: isOutline
                ? Border.all(
              color: borderColor ?? Colors.black,
              width: 2,
            )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
