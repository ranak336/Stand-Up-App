import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _bookings => _firestore.collection('bookings');

  Future<bool> isDateBooked(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final query = await _bookings
        .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
        .where('status', isEqualTo: 'confirmed')
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  Stream<QuerySnapshot> bookingsByMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    return _bookings
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .where('status', isEqualTo: 'confirmed')
        .snapshots();
  }

  Stream<QuerySnapshot> allConfirmedBookings() {
    return _bookings.where('status', isEqualTo: 'confirmed').snapshots();
  }

  Future<void> createBooking({
    required String sessionType,
    required DateTime date,
    required String topic,
    required String topicTitle,
    required String visibility,
    required String backupPerson,
    required List<String> groupMembers,
  }) async {

    final user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;

    /// جلب اسم المستخدم من Firestore
    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final userName = userDoc.data()?['name'] ?? 'User';

    final dateOnly = DateTime(date.year, date.month, date.day);

    final docRef = FirebaseFirestore.instance.collection('bookings').doc();

    await docRef.set({
      'bookingId': docRef.id,
      'userId': uid,
      'userEmail': user.email ?? '',
      'userName': userName,
      'sessionType': sessionType,
      'date': Timestamp.fromDate(dateOnly),
      'topic': topic,
      'topicTitle': topicTitle,
      'visibility': visibility,
      'backupPerson': backupPerson,
      'groupMembers': groupMembers,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}