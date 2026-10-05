import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icons.dart';
import '../../core/theme.dart';
import '../../data/local/daos/content_dao.dart';
import '../../models/grammar_model.dart';
import '../../models/topic_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';
import '../flashcard/flashcard_screen.dart';
import '../grammar/grammar_detail_screen.dart';

class TopicScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const TopicScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends ConsumerState<TopicScreen> {
  String searchQuery = '';
  ProgressFilter selectedFilter = ProgressFilter.all;

  static const _filterLabels = {
    ProgressFilter.all: 'Tất cả',
    ProgressFilter.inProgress: 'Đang học',
    ProgressFilter.completed: 'Đã hoàn thành',
  };

  ListQuery get _query => (filter: selectedFilter, keyword: searchQuery);

  Future<void> _refresh() => ref.read(syncWorkerProvider).syncNow();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialIndex,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: Navigator.of(context).canPop(),
          elevation: 0,
          title: const Text('Học tập', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final topics = ref.watch(topicsProvider(_query));
    return Column(
      children: [
        _buildSearchBar('Tìm chủ đề, từ vựng...'),
        _buildFilterChips(),
        Expanded(
          child: _asyncList<Topic>(topics, (t) => _buildVocabularyCard(context, t)),
        ),
      ],
    );
  }

  Widget _buildGrammarTab(BuildContext context) {
    final grammar = ref.watch(grammarListProvider(_query));
    return Column(
      children: [
        _buildSearchBar('Tìm điểm ngữ pháp...'),
        _buildFilterChips(),
        Expanded(
          child: _asyncList<Grammar>(grammar, (g) => _buildGrammarCard(context, g)),
        ),
      ],
    );
  }

  Widget _asyncList<T>(AsyncValue<List<T>> value, Widget Function(T) itemBuilder) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Không đọc được dữ liệu: $e', style: const TextStyle(color: AppTheme.greyColor))),
      data: (list) => RefreshIndicator(
        onRefresh: _refresh,
        child: list.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Text(
                      searchQuery.isEmpty && selectedFilter == ProgressFilter.all
                          ? 'Chưa có nội dung. Kéo xuống để đồng bộ.'
                          : 'Không tìm thấy kết quả nào',
                      style: const TextStyle(color: AppTheme.greyColor),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
                itemCount: list.length,
                itemBuilder: (context, index) => itemBuilder(list[index]),
              ),
      ),
    );
  }

  Widget _buildSearchBar(String hint) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, color: AppTheme.greyColor),
          filled: true,
          fillColor: Theme.of(context).cardColor,
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
          for (final f in ProgressFilter.values) ...[
            _buildChip(f),
            if (f != ProgressFilter.values.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(ProgressFilter filter) {
    final isActive = selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          _filterLabels[filter]!,
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FlashcardScreen(topicId: topic.id, topicTitle: topic.title)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: isIconName(topic.iconPath)
                    ? Icon(iconFor(topic.iconPath), color: AppTheme.primaryColor)
                    : Text(topic.iconPath, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('${topic.totalWords} từ • ${topic.level}', style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: topic.progress,
                          backgroundColor: Colors.grey.shade200,
                          color: topic.status == 'COMPLETED' ? Colors.green : AppTheme.primaryColor,
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
    final done = grammar.status == 'COMPLETED';
    final started = grammar.status == 'IN_PROGRESS';
    final iconBgColor = done ? Colors.green.shade400 : (started ? Colors.deepPurple.shade400 : Colors.blue.shade300);
    final statusColor = done ? Colors.green : AppTheme.greyColor;

    final Widget trailingIcon = done
        ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
        : Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: started ? Colors.blueAccent : Colors.grey.shade300, width: 2.5)));

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GrammarDetailScreen(grammarId: grammar.id, title: grammar.title)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))]),
        child: Row(
          children: [
            Container(
              width: 50, height: 50, decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(iconFor(grammar.iconName, fallback: Icons.account_tree_outlined), color: Theme.of(context).cardColor, size: 26),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(grammar.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(grammar.statusLabel, style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500)),
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
