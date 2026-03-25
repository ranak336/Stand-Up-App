import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';

class StreakService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> checkTuesdayStreak(BuildContext context) async {
    if (!context.mounted) return;

    final user = AuthService().currentUser;
    if (user == null) return;

    final uid = user.uid;
    final today = DateTime.now();

    //if (today.weekday != DateTime.tuesday) return;
    if (today.weekday != DateTime.thursday) return; // للتجربة فقط

    final userRef = _firestore.collection('users').doc(uid);
    final userDoc = await userRef.get();
    final data = userDoc.data() ?? {};

    final Timestamp? lastCheckTimestamp = data['lastCheckDate'];
    final DateTime? lastCheckDate = lastCheckTimestamp?.toDate();

    if (lastCheckDate != null &&
        lastCheckDate.year == today.year &&
        lastCheckDate.month == today.month &&
        lastCheckDate.day == today.day) {
      return;
    }

    await _showAttendancePopup(context, uid, today);
  }

  static Future<void> _showAttendancePopup(
      BuildContext context,
      String uid,
      DateTime today,
      ) async {
    bool? attended = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Stand-up Meeting"),
        content: const Text("Did you attend today's stand-up meeting?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    attended ??= false;

    final userRef = _firestore.collection('users').doc(uid);
    final userDoc = await userRef.get();
    final data = userDoc.data() ?? {};

    int streak = (data['currentStreak'] ?? 0) as int;
    int reward = (data['rewardPoints'] ?? 0) as int;
    bool bonusGiven = (data['bonusGiven'] ?? false) as bool;

    if (attended) {
      streak += 1;
      reward += 1;

      if (streak >= 8 && !bonusGiven) {
        reward += 5;
        bonusGiven = true;
      }
    } else {
      streak = 0;
    }

    await userRef.set({
      'currentStreak': streak,
      'rewardPoints': reward,
      'bonusGiven': bonusGiven,
      'lastCheckDate': Timestamp.fromDate(today),
    }, SetOptions(merge: true));

    if (attended) {
      await _saveMeetingHistory(
        uid: uid,
        title: "Today's Stand-up",
        status: "Attended",
        date: today,
      );

      await _showParticipationPopup(context, uid, today);
    }
  }

  static Future<void> _showParticipationPopup(
      BuildContext context,
      String uid,
      DateTime today,
      ) async {
    bool? participated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Participation"),
        content: const Text("Did you participate in the session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes (+2)"),
          ),
        ],
      ),
    );

    if (participated == true) {
      final userRef = _firestore.collection('users').doc(uid);
      final userDoc = await userRef.get();
      final data = userDoc.data() ?? {};

      int reward = (data['rewardPoints'] ?? 0) as int;
      reward += 2;

      await userRef.set({
        'rewardPoints': reward,
      }, SetOptions(merge: true));

      await _saveMeetingHistory(
        uid: uid,
        title: "Today's Stand-up",
        status: "Participated",
        date: today,
      );
    }
  }

  static Future<void> _saveMeetingHistory({
    required String uid,
    required String title,
    required String status,
    required DateTime date,
  }) async {
    final docId = "${date.year}-${date.month}-${date.day}";

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('meeting_history')
        .doc(docId)
        .set({
      'title': title,
      'status': status,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<int> getStreak() async {
    final user = AuthService().currentUser;
    if (user == null) return 0;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};
    return (data['currentStreak'] ?? 0) as int;
  }

  static Future<int> getRewardPoints() async {
    final user = AuthService().currentUser;
    if (user == null) return 0;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};
    return (data['rewardPoints'] ?? 0) as int;
  }
}