import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'streak_service.dart';
import 'welcome_page.dart';
import 'rewards_page.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "No date";
    final date = timestamp.toDate();
    const months = [
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
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  Map<String, dynamic> _getNextReward(int points) {
    if (points < 10) {
      return {
        'title': 'Coffee Coupon',
        'needed': 10,
        'icon': Icons.free_breakfast,
        'color': const Color(0xFFFFC107),
      };
    } else if (points < 20) {
      return {
        'title': 'Half Day Off',
        'needed': 20,
        'icon': Icons.access_time,
        'color': const Color(0xFF64B5F6),
      };
    } else if (points < 30) {
      return {
        'title': '1 Hour Permission',
        'needed': 30,
        'icon': Icons.confirmation_num_outlined,
        'color': const Color(0xFFCE93D8),
      };
    } else if (points < 40) {
      return {
        'title': 'Full Day Off',
        'needed': 40,
        'icon': Icons.calendar_today,
        'color': const Color(0xFF00C853),
      };
    } else {
      return {
        'title': 'All rewards unlocked',
        'needed': 40,
        'icon': Icons.emoji_events,
        'color': const Color(0xFF386641),
      };
    }
  }

  Widget _buildNextRewardBanner(int points) {
    final reward = _getNextReward(points);
    final String title = reward['title'] as String;
    final int needed = reward['needed'] as int;
    final IconData icon = reward['icon'] as IconData;
    final Color color = reward['color'] as Color;

    final int remaining = (needed - points).clamp(0, 9999);
    final double progress =
    needed == 0 ? 1 : (points / needed).clamp(0, 1).toDouble();

    final String message = points >= 40
        ? "You have unlocked all available rewards."
        : "You have $points points. Only $remaining points left to get $title.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.95),
            const Color(0xFF386641),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.18),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  points >= 40 ? "Rewards Status" : "Next Reward",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;
    final userEmail = user?.email ?? "demo@company.com";
    final uid = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF386641),
      ),
      body: uid == null
          ? const Center(child: Text("No user found"))
          : FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data();
          final userName =
          data?['name']?.toString().trim().isNotEmpty == true
              ? data!['name'].toString()
              : "User";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// USER CARD
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFF386641),
                          child:
                          Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.email, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(userEmail)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// STATS + NEXT REWARD BANNER
                FutureBuilder<List<int>>(
                  future: Future.wait([
                    StreakService.getStreak(),
                    StreakService.getRewardPoints(),
                  ]),
                  builder: (context, streakSnapshot) {
                    if (streakSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final streak = streakSnapshot.data?[0] ?? 0;
                    final points = streakSnapshot.data?[1] ?? 0;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "$streak",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text("Day Streak"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.emoji_events,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "$points",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text("Total Points"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildNextRewardBanner(points),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                /// REWARD BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "View Rewards",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF386641),
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RewardsPage(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                /// MEETING HISTORY TITLE
                const Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Color(0xFF386641),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Meeting History",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// MEETING HISTORY LIST
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('meeting_history')
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, historySnapshot) {
                    if (historySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!historySnapshot.hasData ||
                        historySnapshot.data!.docs.isEmpty) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              "No meeting history yet",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    }

                    final docs = historySnapshot.data!.docs;

                    return Column(
                      children: docs.map((doc) {
                        final item = doc.data();
                        final title = item['title']?.toString() ??
                            "Stand-up Meeting";
                        final status =
                            item['status']?.toString() ?? "Attended";
                        final date = item['date'] as Timestamp?;

                        final bool participated =
                            status.toLowerCase() == "participated";

                        return Padding(
                          padding:
                          const EdgeInsets.only(bottom: 14),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding:
                              const EdgeInsets.all(18),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatDate(date),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: participated
                                          ? Colors.green.shade100
                                          : Colors.orange.shade100,
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: participated
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 16),

                /// LOGOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.black),
                    label: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () async {
                      await auth.logout();

                      if (!context.mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WelcomePage(),
                        ),
                            (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}