import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/icons.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/content_repository.dart';
import '../../models/flashcard_model.dart';
import '../../models/grammar_model.dart';
import '../../models/topic_model.dart';
import '../../widgets/common.dart';
import '../flashcard/flashcard_screen.dart';
import '../grammar/grammar_detail_screen.dart';

class TopicScreen extends StatefulWidget {
  final int initialIndex;

  const TopicScreen({super.key, this.initialIndex = 0});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialIndex,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Text(tr('Học tập'), style: const TextStyle(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.greyColor,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            tabs: [Tab(text: tr('Từ vựng')), Tab(text: tr('Ngữ pháp'))],
          ),
        ),
        body: const TabBarView(children: [_VocabularyTab(), _GrammarTab()]),
      ),
    );
  }
}

/// Thanh tìm kiếm + bộ lọc dùng chung cho hai tab.
class _SearchAndFilter extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ProgressFilter filter;
  final ValueChanged<String> onChanged;
  final ValueChanged<ProgressFilter> onFilter;

  const _SearchAndFilter({
    required this.controller,
    required this.hint,
    required this.filter,
    required this.onChanged,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search, color: AppTheme.greyColor),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            children: [
              _chip(context, tr('Tất cả'), ProgressFilter.all),
              const SizedBox(width: 10),
              _chip(context, tr('Đang học'), ProgressFilter.inProgress),
              const SizedBox(width: 10),
              _chip(context, tr('Đã hoàn thành'), ProgressFilter.completed),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, ProgressFilter value) {
    final active = filter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: active ? null : Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        child: Text(label,
            style: TextStyle(color: active ? Colors.white : AppTheme.greyColor, fontWeight: FontWeight.w500, fontSize: 13)),
      ),
    );
  }
}

class _VocabularyTab extends StatefulWidget {
  const _VocabularyTab();

  @override
  State<_VocabularyTab> createState() => _VocabularyTabState();
}

class _VocabularyTabState extends State<_VocabularyTab> with AutomaticKeepAliveClientMixin {
  final _search = TextEditingController();
  Timer? _debounce;
  ProgressFilter _filter = ProgressFilter.all;
  List<Topic> _topics = const [];
  List<Flashcard> _words = const [];
  bool _loading = true;
  String? _error;
  int _requestId = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = ++_requestId;
    final keyword = _search.text.trim();
    setState(() {
      _loading = _topics.isEmpty;
      _error = null;
    });
    try {
      final topics = await ContentRepository.allPages<Topic>(
          (page) => ContentRepository.topics(status: _filter, keyword: keyword, page: page, size: 100));
      // Tìm theo từ khoá thì tìm cả từ vựng khớp (từ hoặc nghĩa)
      List<Flashcard> words = const [];
      if (keyword.length >= 2 && _filter == ProgressFilter.all) {
        words = (await ContentRepository.searchFlashcards(keyword, size: 10)).items;
      }
      if (!mounted || id != _requestId) return;
      setState(() {
        _topics = topics;
        _words = words;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = errorMessage(e);
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  Future<void> _openTopic(String id, String title) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardScreen(topicId: id, topicTitle: title)));
    if (mounted) _load();
  }

  Future<void> _openWord(Flashcard word) async {
    try {
      final topic = await ContentRepository.topic(word.topicId);
      if (mounted) await _openTopic(topic.id, topic.title);
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        _SearchAndFilter(
          controller: _search,
          hint: tr('Tìm chủ đề, từ vựng...'),
          filter: _filter,
          onChanged: _onSearchChanged,
          onFilter: (f) {
            setState(() => _filter = f);
            _load();
          },
        ),
        Expanded(child: _body(context)),
      ],
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_topics.isEmpty && _words.isEmpty) return EmptyView(message: tr('Không tìm thấy kết quả nào'), icon: Icons.search_off);
    final bottom = MediaQuery.of(context).padding.bottom;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 100 + bottom),
        children: [
          for (final topic in _topics) _topicCard(context, topic),
          if (_words.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(tr('Từ vựng tìm thấy'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            for (final word in _words) _wordTile(context, word),
          ],
        ],
      ),
    );
  }

  Widget _topicCard(BuildContext context, Topic topic) {
    return GestureDetector(
      onTap: () => _openTopic(topic.id, topic.title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(topic.iconPath, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(topic.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      _levelBadge(topic.level),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(trf('{n} từ', {'n': topic.totalWords}), style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
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
                      Text('${(topic.progress * 100).round()}%', style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
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

  Widget _wordTile(BuildContext context, Flashcard word) {
    return GestureDetector(
      onTap: () => _openWord(word),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${word.word}  ${word.pronunciation}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(word.meaning, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.greyColor),
          ],
        ),
      ),
    );
  }
}

Widget _levelBadge(String level) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
    child: Text(level, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
  );
}

class _GrammarTab extends StatefulWidget {
  const _GrammarTab();

  @override
  State<_GrammarTab> createState() => _GrammarTabState();
}

class _GrammarTabState extends State<_GrammarTab> with AutomaticKeepAliveClientMixin {
  final _search = TextEditingController();
  Timer? _debounce;
  ProgressFilter _filter = ProgressFilter.all;
  List<Grammar> _lessons = const [];
  bool _loading = true;
  String? _error;
  int _requestId = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = ++_requestId;
    setState(() {
      _loading = _lessons.isEmpty;
      _error = null;
    });
    try {
      final lessons = await ContentRepository.allPages<Grammar>(
          (page) => ContentRepository.grammarLessons(status: _filter, keyword: _search.text, page: page, size: 100));
      if (!mounted || id != _requestId) return;
      setState(() {
        _lessons = lessons;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = errorMessage(e);
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        _SearchAndFilter(
          controller: _search,
          hint: tr('Tìm điểm ngữ pháp...'),
          filter: _filter,
          onChanged: _onSearchChanged,
          onFilter: (f) {
            setState(() => _filter = f);
            _load();
          },
        ),
        Expanded(child: _body(context)),
      ],
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_lessons.isEmpty) return EmptyView(message: tr('Không tìm thấy kết quả nào'), icon: Icons.search_off);
    final bottom = MediaQuery.of(context).padding.bottom;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 100 + bottom),
        itemCount: _lessons.length,
        itemBuilder: (context, i) => _grammarCard(context, _lessons[i]),
      ),
    );
  }

  String _statusText(Grammar g) {
    final pct = (g.progress * 100).round();
    switch (g.status) {
      case 'COMPLETED':
        return trf('Đã học {p}%', {'p': 100});
      case 'IN_PROGRESS':
        return trf('Đang học {p}%', {'p': pct});
      default:
        return trf('Chưa học {p}%', {'p': 0});
    }
  }

  Widget _grammarCard(BuildContext context, Grammar grammar) {
    final done = grammar.status == 'COMPLETED';
    final started = grammar.status == 'IN_PROGRESS';
    final iconBg = done ? Colors.green.shade400 : (started ? Colors.deepPurple.shade400 : Colors.blue.shade300);
    final statusColor = done ? Colors.green : AppTheme.greyColor;
    final trailing = done
        ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
        : Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                shape: BoxShape.circle, border: Border.all(color: started ? Colors.blueAccent : Colors.grey.shade300, width: 2.5)),
          );
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context, MaterialPageRoute(builder: (_) => GrammarDetailScreen(grammarId: grammar.id, title: grammar.title)));
        if (mounted) _load();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(grammarIcon(grammar.iconName), color: Colors.white, size: 26),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(grammar.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      _levelBadge(grammar.level),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(_statusText(grammar), style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing,
          ],
        ),
      ),
    );
  }
}
