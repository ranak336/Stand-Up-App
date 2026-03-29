import 'package:flutter/material.dart';
import 'streak_service.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  Widget _rewardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int points,
    required List<Color> gradientColors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(colors: gradientColors),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFF386641), size: 30),
                const SizedBox(width: 10),
                Text(
                  "$points",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "points",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A4B),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Redeem",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _earnPointsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, color: Color(0xFF386641), size: 30),
              SizedBox(width: 10),
              Text(
                "How to Earn Points",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text("• Attend daily meetings: +2 points", style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("• Participate in meetings: +5 points", style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("• Present a session: +10 points", style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("• Maintain streaks: Bonus points", style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rewards",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF386641),
      ),
      body: FutureBuilder<int>(
        future: StreakService.getRewardPoints(),
        builder: (context, snapshot) {
          final points = snapshot.data ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF386641),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 48,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Available Points",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "$points",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _rewardCard(
                  icon: Icons.free_breakfast,
                  title: "Coffee Coupon",
                  subtitle: "Enjoy a free coffee on us",
                  points: 10,
                  gradientColors: const [Color(0xFFFFC107), Color(0xFFFF8F00)],
                ),

                _rewardCard(
                  icon: Icons.access_time,
                  title: "Half Day Off",
                  subtitle: "Take half a day to recharge",
                  points: 20,
                  gradientColors: const [Color(0xFF64B5F6), Color(0xFF2962FF)],
                ),

                _rewardCard(
                  icon: Icons.confirmation_num_outlined,
                  title: "1 Hour Permission",
                  subtitle: "Leave work an hour early",
                  points: 30,
                  gradientColors: const [Color(0xFFCE93D8), Color(0xFFAA00FF)],
                ),

                _rewardCard(
                  icon: Icons.calendar_today,
                  title: "Full Day Off",
                  subtitle: "Enjoy a full day of rest",
                  points: 40,
                  gradientColors: const [Color(0xFF00E676), Color(0xFF00C853)],
                ),

                const SizedBox(height: 10),
                _earnPointsCard(),
              ],
            ),
          );
        },
      ),
    );
  }
}
