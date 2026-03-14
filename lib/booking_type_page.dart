import 'package:flutter/material.dart';
import 'booking_flow_data.dart';
import 'booking_widgets.dart';
import 'group_members_page.dart';
import 'select_month_page.dart';

class BookingTypePage extends StatefulWidget {
  const BookingTypePage({super.key});

  @override
  State<BookingTypePage> createState() => _BookingTypePageState();
}

class _BookingTypePageState extends State<BookingTypePage> {
  String selectedType = 'individual';

  @override
  Widget build(BuildContext context) {
    return BookingScaffold(
      title: 'Book a Session',
      step: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Session Type',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select whether this is an individual or group session',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          OutlineCardButton(
            title: 'Individual',
            subtitle: 'Present on your own',
            icon: Icons.person_outline,
            selected: selectedType == 'individual',
            onTap: () => setState(() => selectedType = 'individual'),
          ),
          const SizedBox(height: 16),
          OutlineCardButton(
            title: 'Group',
            subtitle: 'Present with your team',
            icon: Icons.groups_2_outlined,
            selected: selectedType == 'group',
            onTap: () => setState(() => selectedType = 'group'),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Next',
            onPressed: () {
              final data = BookingFlowData(sessionType: selectedType);

              if (selectedType == 'group') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupMembersPage(data: data),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectMonthPage(data: data),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}