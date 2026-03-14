import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'profile.dart';
import 'booking_type_page.dart';
import 'calendar_page.dart';

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<bool> monthlyFires = List.generate(4, (_) => false);
  int currentMonth = DateTime.now().month;
  int todaySaturdayIndex = -1;
  bool popupShown = false;

  @override
  void initState() {
    super.initState();
    calculateSaturdayIndex();
    checkForPopup();
  }

  void calculateSaturdayIndex() {
    DateTime now = DateTime.now();
    DateTime firstDay = DateTime(now.year, now.month, 1);

    int count = 0;

    for (int i = 0; i < now.day; i++) {
      DateTime day = firstDay.add(Duration(days: i));

      if (day.weekday == DateTime.saturday) {
        if (day.day == now.day) {
          todaySaturdayIndex = count;
        }
        count++;
      }
    }
  }

  void checkForPopup() {
    if (DateTime.now().weekday == DateTime.saturday &&
        todaySaturdayIndex != -1 &&
        todaySaturdayIndex < monthlyFires.length &&
        !monthlyFires[todaySaturdayIndex] &&
        !popupShown) {
      popupShown = true;

      Future.delayed(Duration.zero, () {
        showFirePopup(todaySaturdayIndex);
      });
    }
  }

  void markFireCompleted(int index) {
    if (index >= 0 && index < monthlyFires.length) {
      setState(() {
        monthlyFires[index] = true;
      });
    }
  }

  void resetIfNewMonth() {
    int monthNow = DateTime.now().month;

    if (monthNow != currentMonth) {
      currentMonth = monthNow;

      setState(() {
        monthlyFires = List.generate(4, (_) => false);
      });
    }
  }

  void showFirePopup(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: const Text("Did you participate?"),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text("Skip", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Yes (+2)"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                markFireCompleted(index);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _handleMenuTap(String title) {
    if (title == "Booking") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookingTypePage()),
      );
    } else if (title == "Calendar") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CalendarPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$title page is not connected yet")),
      );
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getUpcomingSessionStream() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return FirebaseFirestore.instance
        .collection('bookings')
        .where('status', isEqualTo: 'confirmed')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .orderBy('date')
        .limit(1)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    resetIfNewMonth();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              height: 260,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: const BoxDecoration(
                color: Color(0xFF386641),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// TOP ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.person_pin,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Profile(),
                            ),
                          );
                        },
                      ),
                      const Row(
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Hello, ${widget.userName}! 👋",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Let's make today productive",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// FIRE STREAK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                          (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.local_fire_department,
                          color: monthlyFires[index]
                              ? Colors.orange
                              : Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// MENU TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Menu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// MENU GRID
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.05,
              children: [
                _buildCard("Booking", Icons.edit_document),
                _buildCard("Explore Themes", Icons.lightbulb_outline),
                _buildCard("News", Icons.newspaper),
                _buildCard("Calendar", Icons.calendar_month),
              ],
            ),

            const SizedBox(height: 28),

            /// UPCOMING SESSION TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Upcoming Session",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// UPCOMING SESSION CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _getUpcomingSessionStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: Text(
                        "No upcoming session",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "No upcoming session",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF386641),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Your next booked session will appear here.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = docs.first.data();
                  final Timestamp timestamp = data['date'] as Timestamp;
                  final DateTime sessionDate = timestamp.toDate();

                  final String topic = (data['topicTitle'] != null &&
                      data['topicTitle'].toString().trim().isNotEmpty)
                      ? data['topicTitle'].toString()
                      : (data['topic'] ?? 'Stand-up Session').toString();

                  final String sessionType =
                  (data['sessionType'] ?? 'individual').toString();
                  final String visibility =
                  (data['visibility'] ?? 'Public').toString();
                  final String userName =
                  (data['userName'] ?? 'User').toString();

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green[50],
                              child: const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF386641),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                topic,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF386641),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Presenter: $userName",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Date: ${DateFormat('EEEE, MMMM d, yyyy').format(sessionDate)}",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Type: ${sessionType[0].toUpperCase()}${sessionType.substring(1)}",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Visibility: $visibility",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _handleMenuTap(title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green[50],
              child: Icon(icon, color: const Color(0xFF386641)),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}