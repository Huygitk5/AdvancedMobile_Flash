import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../../models/topic_model.dart';
import '../../models/grammar_model.dart';
import '../flashcard/flashcard_screen.dart';
import '../grammar/grammar_detail_screen.dart';

class TopicScreen extends StatefulWidget {
  final int initialIndex;

  const TopicScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  // Các biến lưu trữ trạng thái tìm kiếm và bộ lọc
  String searchQuery = '';
  String selectedFilter = 'Tất cả';

  // Hàm xử lý logic lọc Từ vựng
  List<Topic> get filteredVocabulary {
    return MockData.vocabularyTopics.where((topic) {
      // 1. Lọc theo tên (Search)
      bool matchSearch = topic.title.toLowerCase().contains(searchQuery.toLowerCase());

      // 2. Lọc theo trạng thái (Filter Chips)
      bool matchFilter = true;
      if (selectedFilter == 'Đang học') {
        matchFilter = topic.progress > 0 && topic.progress < 1.0;
      } else if (selectedFilter == 'Đã hoàn thành') {
        matchFilter = topic.progress >= 1.0;
      }

      return matchSearch && matchFilter;
    }).toList();
  }

  List<Grammar> get filteredGrammar {
    return MockData.grammarTopics.where((grammar) {
      bool matchSearch = grammar.title.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchFilter = true;
      if (selectedFilter == 'Đang học') {
        matchFilter = grammar.progress > 0 && grammar.progress < 1.0;
      } else if (selectedFilter == 'Hoàn thành') {
        matchFilter = grammar.progress >= 1.0;
      }
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          automaticallyImplyLeading: false, // Đã ẩn nút Back
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
    final list = filteredVocabulary; // Lấy danh sách đã được lọc

    return Column(
      children: [
        _buildSearchBar('Tìm chủ đề, từ vựng...'),
        _buildFilterChips(),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('Không tìm thấy kết quả nào', style: TextStyle(color: AppTheme.greyColor)))
              : ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _buildVocabularyCard(context, list[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGrammarTab(BuildContext context) {
    final list = filteredGrammar; // Lấy danh sách đã được lọc

    return Column(
      children: [
        _buildSearchBar('Tìm điểm ngữ pháp...'),
        _buildFilterChips(),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('Không tìm thấy kết quả nào', style: TextStyle(color: AppTheme.greyColor)))
              : ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _buildGrammarCard(context, list[index]);
            },
          ),
        ),
      ],
    );
  }

  // Cập nhật thanh tìm kiếm để nhận sự kiện gõ phím
  Widget _buildSearchBar(String hint) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value; // Cập nhật từ khóa tìm kiếm
          });
        },
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
          _buildChip('Tất cả'),
          const SizedBox(width: 10),
          _buildChip('Đang học'),
          const SizedBox(width: 10),
          _buildChip('Đã hoàn thành'),
        ],
      ),
    );
  }

  // Cập nhật Nút bấm bộ lọc để nhận sự kiện click
  Widget _buildChip(String label) {
    bool isActive = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label; // Cập nhật bộ lọc được chọn
        });
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildVocabularyCard(BuildContext context, Topic topic) {
    return GestureDetector(
      onTap: () {
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

  Widget _buildGrammarCard(BuildContext context, Grammar grammar) {
    double progress = grammar.progress;
    Color iconBgColor = progress == 1.0 ? Colors.green.shade400 : (progress > 0 ? Colors.deepPurple.shade400 : Colors.blue.shade300);
    Color statusColor = progress == 1.0 ? Colors.green : AppTheme.greyColor;

    Widget trailingIcon = progress == 1.0
        ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
        : Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: progress > 0 ? Colors.blueAccent : Colors.grey.shade300, width: 2.5)));

    // Map string từ API sang Icon Flutter
    IconData getIcon(String name) {
      switch (name) {
        case 'access_alarm': return Icons.access_alarm;
        case 'history_edu': return Icons.history_edu;
        case 'verified_user': return Icons.verified_user_outlined;
        case 'alt_route': return Icons.alt_route;
        default: return Icons.account_tree_outlined;
      }
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GrammarDetailScreen(title: grammar.title))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))]),
        child: Row(
          children: [
            Container(
              width: 50, height: 50, decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(getIcon(grammar.iconName), color: Colors.white, size: 26),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(grammar.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 5),
                  Text(grammar.status, style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500)),
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