
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stand_up/streak_service.dart';
import 'auth_service.dart';

import 'profile.dart';
import 'booking_type_page.dart';
import 'calendar_page.dart';
import 'explore_themes_page.dart';

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadStreak();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await StreakService.checkTuesdayStreak(context);
      if (!mounted) return;
      _loadStreak();
    });
  }

  Future<void> _loadStreak() async {
    int streak = await StreakService.getStreak();
    if (!mounted) return;
    setState(() {
      currentStreak = streak;
    });
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
    } else if (title == "Explore Themes") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExploreThemesPage()),
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

  Future<String> _getUserName() async {
    final user = AuthService().currentUser;
    if (user == null) return widget.userName.isNotEmpty ? widget.userName : "User";

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    final name = data?['name']?.toString().trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return widget.userName.isNotEmpty ? widget.userName : "User";
  }

  @override
  Widget build(BuildContext context) {
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
                    child: FutureBuilder<String>(
                      future: _getUserName(),
                      builder: (context, snapshot) {
                        final name = snapshot.data ?? widget.userName;
                        return Text(
                          "Hello, $name! 👋",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
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
                  SizedBox(
                    height: 30,
                    child: FutureBuilder<int>(
                      future: StreakService.getStreak(),
                      builder: (context, snapshot) {
                        int streak = snapshot.data ?? 0;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                                (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                Icons.local_fire_department,
                                color: index < streak
                                    ? Colors.orange
                                    : Colors.white,
                                size: 28,
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

            /// UPCOMING SESSION
            /// UPCOMING SESSION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Upcoming Session",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF386641),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _getUpcomingSessionStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _loadingCard();
                  }
                  if (snapshot.hasError) return _noSessionCard();
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) return _noSessionCard();

                  final data = docs.first.data();
                  final Timestamp timestamp = data['date'] as Timestamp;
                  final DateTime sessionDate = timestamp.toDate();
                  final String topic =
                  (data['topicTitle'] ?? 'Stand-up Session').toString();
                  final String userName =
                  (data['userName'] ?? 'User').toString();

                  return _sessionCard(topic, userName, sessionDate);
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

  Widget _loadingCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
    ),
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _noSessionCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
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

  Widget _sessionCard(String topic, String userName, DateTime sessionDate) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
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
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              "Date: ${DateFormat('EEEE, MMMM d, yyyy').format(sessionDate)}",
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      );
}