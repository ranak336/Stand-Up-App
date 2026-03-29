
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsPage extends StatelessWidget {
  NewsPage({super.key});

  // Firestore reference
  final CollectionReference newsRef = FirebaseFirestore.instance.collection(
    'news',
  );

  // Dummy data for when Firestore is empty
  final List<Map<String, String>> dummyNews = const [
    {
      'title': "Welcome to the app 🎉",
      'description': "Start exploring and enjoy your tasks!",
    },
    {
      'title': "Tips for productivity",
      'description': "Check out daily tips to stay focused and motivated.",
    },
    {
      'title': "Upcoming features",
      'description': "News page will soon support images and full articles.",
    },
  ];

  ///if the database has data it will retrieve it otherwise the dummy data will appear
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "News",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: newsRef.orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          final hasData = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
          final newsList = hasData
              ? snapshot.data!.docs
              : dummyNews; // Either Firestore docs or dummy

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF386641)),
            );
          }

          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              late String title;
              late String description;

              if (hasData) {
                final doc = newsList[index] as QueryDocumentSnapshot;
                final data = doc.data() as Map<String, dynamic>;
                title = data['title'] ?? '';
                description = data['description'] ?? '';
              } else {
                final data = newsList[index] as Map<String, String>;
                title = data['title']!;
                description = data['description']!;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF386641), width: 1),
                ),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF386641).withOpacity(0.2),
                    child: const Icon(
                      Icons.newspaper,
                      color: Color(0xFF386641),
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF386641),
                    ),
                  ),
                  subtitle: Text(
                    description,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
