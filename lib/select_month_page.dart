import 'package:flutter/material.dart';
import 'booking_flow_data.dart';
import 'booking_widgets.dart';
import 'select_date_page.dart';

class SelectMonthPage extends StatefulWidget {
  final BookingFlowData data;

  const SelectMonthPage({super.key, required this.data});

  @override
  State<SelectMonthPage> createState() => _SelectMonthPageState();
}

class _SelectMonthPageState extends State<SelectMonthPage> {
  late List<DateTime> months;
  DateTime? selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    months = List.generate(
      6,
          (index) => DateTime(now.year, now.month + index, 1),
    );
    selectedMonth = months.first;
  }

  String _monthName(DateTime date) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${names[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BookingScaffold(
      title: 'Book a Session',
      step: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pick a Month',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose the month you want to book in',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ...months.map((month) {
            final selected = selectedMonth == month;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: () => setState(() => selectedMonth = month),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFEAF6EF) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? kPrimaryGreen : kCardBorder,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: kPrimaryGreen),
                      const SizedBox(width: 12),
                      Text(
                        _monthName(month),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: kDarkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Next',
            onPressed: () {
              widget.data.selectedMonth = selectedMonth;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectDatePage(data: widget.data),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}