import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'booking_flow_data.dart';
import 'booking_service.dart';
import 'booking_widgets.dart';
import 'select_topic_page.dart';

class SelectDatePage extends StatefulWidget {
  final BookingFlowData data;

  const SelectDatePage({super.key, required this.data});

  @override
  State<SelectDatePage> createState() => _SelectDatePageState();
}

class _SelectDatePageState extends State<SelectDatePage> {
  final BookingService _bookingService = BookingService();
  DateTime? selectedDate;

  List<DateTime> _getTuesdaysInMonth(DateTime month) {
    final dates = <DateTime>[];
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    for (
    DateTime day = firstDay;
    !day.isAfter(lastDay);
    day = day.add(const Duration(days: 1))
    ) {
      if (day.weekday == DateTime.tuesday) {
        dates.add(DateTime(day.year, day.month, day.day));
      }
    }
    return dates;
  }

  bool _isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final month = widget.data.selectedMonth!;
    final dates = _getTuesdaysInMonth(month);

    return BookingScaffold(
      title: 'Book a Session',
      step: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pick a Date',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Available Tuesdays only',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: Future.wait(
              dates.map((date) async {
                final booked = await _bookingService.isDateBooked(date);
                return {
                  'date': date,
                  'booked': booked,
                };
              }),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data!;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final date = items[index]['date'] as DateTime;
                  final booked = items[index]['booked'] as bool;
                  final past = _isPast(date);
                  final disabled = booked || past;
                  final isSelected = selectedDate == date;

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: disabled
                        ? null
                        : () {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEAF6EF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? kPrimaryGreen : kCardBorder,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Opacity(
                        opacity: disabled ? 0.55 : 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('MMM').format(date),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${date.day}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: kDarkText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${date.year}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              booked
                                  ? 'Booked'
                                  : past
                                  ? 'Expired'
                                  : 'Available',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: booked
                                    ? Colors.red
                                    : past
                                    ? Colors.grey
                                    : kPrimaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Next',
            onPressed: selectedDate == null
                ? null
                : () {
              widget.data.selectedDate = selectedDate;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectTopicPage(data: widget.data),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}