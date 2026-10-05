import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icons.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/local/daos/content_dao.dart';
import '../../models/flashcard_model.dart';
import '../../models/grammar_model.dart';
import '../../models/topic_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../flashcard/flashcard_screen.dart';
import '../grammar/grammar_detail_screen.dart';

class TopicScreen extends ConsumerWidget {
  final int initialIndex;

  const TopicScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: Navigator.of(context).canPop(),
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

/// Thanh tìm kiếm + bộ lọc dùng chung cho hai tab (mỗi tab giữ từ khoá / bộ lọc riêng).
class _SearchAndFilter extends StatelessWidget {
  final String hint;
  final ProgressFilter filter;
  final ValueChanged<String> onChanged;
  final ValueChanged<ProgressFilter> onFilter;

  const _SearchAndFilter({required this.hint, required this.filter, required this.onChanged, required this.onFilter});

  static Map<ProgressFilter, String> get _labels => {
        ProgressFilter.all: tr('Tất cả'),
        ProgressFilter.inProgress: tr('Đang học'),
        ProgressFilter.completed: tr('Đã hoàn thành'),
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: TextField(
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
              for (final f in ProgressFilter.values) ...[
                _chip(context, _labels[f]!, f),
                if (f != ProgressFilter.values.last) const SizedBox(width: 10),
              ],
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

/// Danh sách đọc từ SQLite (offline được); kéo xuống để đồng bộ với server.
Widget _asyncList<T>(
  BuildContext context,
  WidgetRef ref,
  AsyncValue<List<T>> value, {
  required bool isFiltering,
  required List<Widget> Function(List<T> items) children,
  List<Widget> extra = const [],
}) {
  Future<void> refresh() => ref.read(syncWorkerProvider).syncNow();
  return value.when(
    loading: () => const LoadingView(),
    error: (e, _) => ErrorView(message: trf('Không đọc được dữ liệu: {e}', {'e': e})),
    data: (list) {
      final bottom = MediaQuery.of(context).padding.bottom;
      return RefreshIndicator(
        onRefresh: refresh,
        child: list.isEmpty && extra.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 60),
                  EmptyView(
                    message: isFiltering ? tr('Không tìm thấy kết quả nào') : tr('Chưa có nội dung. Kéo xuống để đồng bộ.'),
                    icon: isFiltering ? Icons.search_off : Icons.cloud_download_outlined,
                  ),
                ],
              )
            : ListView(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 100 + bottom),
                children: [...children(list), ...extra],
              ),
      );
    },
  );
}

Widget _levelBadge(String level) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
    child: Text(level, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
  );
}

BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 5, offset: const Offset(0, 2))],
    );

class _VocabularyTab extends ConsumerStatefulWidget {
  const _VocabularyTab();

  @override
  ConsumerState<_VocabularyTab> createState() => _VocabularyTabState();
}

class _VocabularyTabState extends ConsumerState<_VocabularyTab> with AutomaticKeepAliveClientMixin {
  String _keyword = '';
  ProgressFilter _filter = ProgressFilter.all;

  @override
  bool get wantKeepAlive => true;

  void _openTopic(String id, String title) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardScreen(topicId: id, topicTitle: title)));

  Future<void> _openWord(Flashcard word) async {
    final topic = await ref.read(dbProvider).contentDao.watchTopic(word.topicId).first;
    if (!mounted) return;
    if (topic == null) {
      showAppSnack(context, tr('Không tìm thấy dữ liệu.'), error: true);
      return;
    }
    _openTopic(topic.id, topic.title);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final topics = ref.watch(topicsProvider((filter: _filter, keyword: _keyword)));
    // Tìm theo từ khoá thì tìm cả từ vựng khớp (từ hoặc nghĩa)
    final keyword = _keyword.trim();
    final searchWords = keyword.length >= 2 && _filter == ProgressFilter.all;
    final words = searchWords ? (ref.watch(searchCardsProvider(keyword)).value ?? const <Flashcard>[]) : const <Flashcard>[];
    return Column(
      children: [
        _SearchAndFilter(
          hint: tr('Tìm chủ đề, từ vựng...'),
          filter: _filter,
          onChanged: (v) => setState(() => _keyword = v),
          onFilter: (f) => setState(() => _filter = f),
        ),
        Expanded(
          child: _asyncList<Topic>(
            context,
            ref,
            topics,
            isFiltering: keyword.isNotEmpty || _filter != ProgressFilter.all,
            children: (list) => [for (final t in list) _topicCard(context, t)],
            extra: [
              if (words.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(tr('Từ vựng tìm thấy'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                for (final word in words) _wordTile(context, word),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _topicCard(BuildContext context, Topic topic) {
    return GestureDetector(
      onTap: () => _openTopic(topic.id, topic.title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(context),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
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
                  Text('${word.word}  ${word.pronunciation}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(word.meaning,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
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

class _GrammarTab extends ConsumerStatefulWidget {
  const _GrammarTab();

  @override
  ConsumerState<_GrammarTab> createState() => _GrammarTabState();
}

class _GrammarTabState extends ConsumerState<_GrammarTab> with AutomaticKeepAliveClientMixin {
  String _keyword = '';
  ProgressFilter _filter = ProgressFilter.all;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final grammar = ref.watch(grammarListProvider((filter: _filter, keyword: _keyword)));
    return Column(
      children: [
        _SearchAndFilter(
          hint: tr('Tìm điểm ngữ pháp...'),
          filter: _filter,
          onChanged: (v) => setState(() => _keyword = v),
          onFilter: (f) => setState(() => _filter = f),
        ),
        Expanded(
          child: _asyncList<Grammar>(
            context,
            ref,
            grammar,
            isFiltering: _keyword.trim().isNotEmpty || _filter != ProgressFilter.all,
            children: (list) => [for (final g in list) _grammarCard(context, g)],
          ),
        ),
      ],
    );
  }

  String _statusText(Grammar g) {
    switch (g.status) {
      case 'COMPLETED':
        return trf('Đã học {p}%', {'p': 100});
      case 'IN_PROGRESS':
        return trf('Đang học {p}%', {'p': (g.progress * 100).round()});
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
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => GrammarDetailScreen(grammarId: grammar.id, title: grammar.title))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(context),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(iconFor(grammar.iconName, fallback: Icons.account_tree_outlined), color: Colors.white, size: 26),
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
