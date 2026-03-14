import 'package:flutter/material.dart';
import 'booking_flow_data.dart';
import 'booking_widgets.dart';
import 'confirm_booking_page.dart';

class MeetingDetailsPage extends StatefulWidget {
  final BookingFlowData data;

  const MeetingDetailsPage({super.key, required this.data});

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  late TextEditingController titleController;
  late TextEditingController backupController;
  String visibility = 'Public';

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.data.topic);
    backupController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    backupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BookingScaffold(
      title: 'Book a Session',
      step: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meeting Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Customize your session',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          const Text(
            'Topic Title (Optional)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Enter topic title',
              filled: true,
              fillColor: Colors.white,
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
          const SizedBox(height: 22),
          const Text(
            'Visibility',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          OutlineCardButton(
            title: 'Public',
            subtitle: 'Everyone can see this session',
            icon: Icons.public,
            selected: visibility == 'Public',
            onTap: () => setState(() => visibility = 'Public'),
          ),
          const SizedBox(height: 14),
          OutlineCardButton(
            title: 'Private',
            subtitle: 'Only invited people can see',
            icon: Icons.lock_outline,
            selected: visibility == 'Private',
            onTap: () => setState(() => visibility = 'Private'),
          ),
          const SizedBox(height: 22),
          const Text(
            'Backup Person (Optional)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: backupController,
            decoration: InputDecoration(
              hintText: 'backup@company.com',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.email_outlined),
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
          const SizedBox(height: 8),
          const Text(
            "We'll send a confirmation email to this person",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Continue',
            onPressed: () {
              widget.data.topicTitle = titleController.text.trim();
              widget.data.visibility = visibility;
              widget.data.backupPerson = backupController.text.trim();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConfirmBookingPage(data: widget.data),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}