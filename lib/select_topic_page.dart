import 'package:flutter/material.dart';
import 'booking_flow_data.dart';
import 'booking_widgets.dart';
import 'meeting_details_page.dart';

class SelectTopicPage extends StatefulWidget {
  final BookingFlowData data;

  const SelectTopicPage({super.key, required this.data});

  @override
  State<SelectTopicPage> createState() => _SelectTopicPageState();
}

class _SelectTopicPageState extends State<SelectTopicPage> {
  final List<String> topics = [
    'Agile Methodologies',
    'Code Review Best Practices',
    'Team Collaboration',
    'Problem Solving Techniques',
    'Technical Debt Management',
    'Communication Skills',
    'Time Management',
    'Leadership Principles',
  ];

  String? selectedTopic;

  @override
  Widget build(BuildContext context) {
    return BookingScaffold(
      title: 'Book a Session',
      step: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pick a Topic',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose from monthly topics',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ...topics.map((topic) {
            final selected = selectedTopic == topic;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: () => setState(() => selectedTopic = topic),
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
                      const Icon(Icons.lightbulb_outline, color: kPrimaryGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          topic,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: kDarkText,
                          ),
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
            text: 'Continue',
            onPressed: selectedTopic == null
                ? null
                : () {
              widget.data.topic = selectedTopic!;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MeetingDetailsPage(data: widget.data),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}