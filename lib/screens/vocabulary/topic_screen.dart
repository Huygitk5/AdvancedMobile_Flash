import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../flashcard/flashcard_screen.dart';
import '../grammar/grammar_detail_screen.dart'; // Đã import màn hình ngữ pháp

class TopicScreen extends StatelessWidget {
  const TopicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Học tập', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.greyColor,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Từ vựng'),
              Tab(text: 'Ngữ pháp'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildVocabularyTab(context),
            _buildGrammarTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabularyTab(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar('Tìm chủ đề, từ vựng...'),
        _buildFilterChips(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: MockData.vocabularyTopics.length,
            itemBuilder: (context, index) {
              final topic = MockData.vocabularyTopics[index];
              return _buildVocabularyCard(context, topic);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGrammarTab(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar('Tìm điểm ngữ pháp...'),
        _buildFilterChips(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: MockData.grammarTopics.length,
            itemBuilder: (context, index) {
              final grammar = MockData.grammarTopics[index];
              return _buildGrammarCard(context, grammar);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(String hint) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, color: AppTheme.greyColor),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          _buildChip('Tất cả', isActive: true),
          const SizedBox(width: 10),
          _buildChip('Đang học', isActive: false),
          const SizedBox(width: 10),
          _buildChip('Đã hoàn thành', isActive: false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppTheme.greyColor,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildVocabularyCard(BuildContext context, dynamic topic) {
    return GestureDetector(
      onTap: () {
        // CHUYỂN SANG MÀN FLASHCARD
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FlashcardScreen(topicTitle: topic.title)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(topic.iconPath, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('${topic.totalWords} từ', style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: topic.progress,
                          backgroundColor: Colors.grey.shade200,
                          color: AppTheme.primaryColor,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${(topic.progress * 100).toInt()}%', style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, color: AppTheme.greyColor),
          ],
        ),
      ),
    );
  }

  Widget _buildGrammarCard(BuildContext context, Map<String, dynamic> grammar) {
    double progress = grammar['progress'];
    Color iconBgColor = progress == 1.0 ? Colors.green.shade400 : (progress > 0 ? Colors.deepPurple.shade400 : Colors.blue.shade300);
    Color statusColor = progress == 1.0 ? Colors.green : AppTheme.greyColor;

    Widget trailingIcon;
    if (progress == 1.0) {
      trailingIcon = const Icon(Icons.check_circle, color: Colors.green, size: 28);
    } else if (progress > 0) {
      trailingIcon = Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blueAccent, width: 2.5)));
    } else {
      trailingIcon = Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 2.5)));
    }

    return GestureDetector(
      onTap: () {
        // CHUYỂN SANG MÀN CHI TIẾT NGỮ PHÁP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GrammarDetailScreen(title: grammar['title']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(grammar['icon'], color: Colors.white, size: 26),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(grammar['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 5),
                  Text(grammar['status'], style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailingIcon,
          ],
        ),
      ),
    );
  }
}