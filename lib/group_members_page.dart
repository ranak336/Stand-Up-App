import 'package:flutter/material.dart';
import 'booking_flow_data.dart';
import 'booking_widgets.dart';
import 'select_month_page.dart';

class GroupMembersPage extends StatefulWidget {
  final BookingFlowData data;

  const GroupMembersPage({super.key, required this.data});

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _goNext() {
    final names = _controllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    widget.data.groupMembers = names;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMonthPage(data: widget.data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BookingScaffold(
      title: 'Book a Session',
      step: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Group Members',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add the names of group members',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ...List.generate(_controllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextField(
                controller: _controllers[index],
                decoration: InputDecoration(
                  hintText: 'Member ${index + 1} name',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: kCardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: kCardBorder),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _addField,
            icon: const Icon(Icons.add),
            label: const Text('Add another member'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimaryGreen,
              side: const BorderSide(color: kPrimaryGreen),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Next',
            onPressed: _goNext,
          ),
        ],
      ),
    );
  }
}
