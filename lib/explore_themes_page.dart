import 'package:flutter/material.dart';

class ExploreThemesPage extends StatefulWidget {
  const ExploreThemesPage({super.key});

  @override
  State<ExploreThemesPage> createState() => _ExploreThemesPageState();
}

class _ExploreThemesPageState extends State<ExploreThemesPage> {
  String selectedCategory = 'All';

  final List<Map<String, String>> topics = [
    {
      'title': 'Agile Methodologies',
      'description': 'Learn practical approaches for agile teamwork and project delivery',
      'category': 'Development',
    },
    {
      'title': 'Code Review Best Practices',
      'description': 'Effective techniques for reviewing code and providing feedback',
      'category': 'Development',
    },
    {
      'title': 'Team Collaboration',
      'description': 'Improve teamwork, trust, and collaboration across your team',
      'category': 'Soft Skills',
    },
    {
      'title': 'Problem Solving Techniques',
      'description': 'Explore structured ways to solve challenges and make decisions',
      'category': 'General',
    },
    {
      'title': 'Technical Debt Management',
      'description': 'Strategies for identifying and reducing technical debt',
      'category': 'Development',
    },
    {
      'title': 'Communication Skills',
      'description': 'Strengthen communication in meetings and daily work',
      'category': 'Soft Skills',
    },
    {
      'title': 'Time Management',
      'description': 'Tips to manage priorities, deadlines, and productivity',
      'category': 'General',
    },
    {
      'title': 'Leadership Principles',
      'description': 'Discover key leadership habits for guiding teams effectively',
      'category': 'Soft Skills',
    },
  ];

  List<Map<String, String>> get filteredTopics {
    if (selectedCategory == 'All') return topics;
    return topics.where((topic) => topic['category'] == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF0B7A4B),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore Themes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Discover topics for your sessions',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip('All'),
                          _buildCategoryChip('Development'),
                          _buildCategoryChip('Soft Skills'),
                          _buildCategoryChip('General'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    const Row(
                      children: [
                        Icon(Icons.star_border, color: Color(0xFF0B7A4B), size: 28),
                        SizedBox(width: 8),
                        Text(
                          'New User-Selected Topics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    ...filteredTopics.map((topic) {
                      return _buildTopicCard(
                        title: topic['title']!,
                        description: topic['description']!,
                        category: topic['category']!,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String title) {
    final bool isSelected = selectedCategory == title;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            selectedCategory = title;
          });
        },
        selectedColor: const Color(0xFF0B7A4B),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF374151),
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isSelected ? const Color(0xFF0B7A4B) : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }

  Widget _buildTopicCard({
    required String title,
    required String description,
    required String category,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF0B7A4B), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFF0B7A4B)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B7A4B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category,
              style: const TextStyle(
                color: Color(0xFF0B7A4B),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}