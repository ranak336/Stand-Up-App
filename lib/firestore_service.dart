import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createBooking({
    required String userId,
    required String topic,
    required String type,
    required DateTime date,
  }) async {
    await _db.collection("bookings").add({
      "userId": userId,
      "topic": topic,
      "type": type,
      "date": date,
      "startTime": "09:00",
      "endTime": "09:25",
      "createdAt": Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getBookings(String userId) {
    return _db
        .collection("bookings")
        .where("userId", isEqualTo: userId)
        .orderBy("date")
        .snapshots();
  }
}