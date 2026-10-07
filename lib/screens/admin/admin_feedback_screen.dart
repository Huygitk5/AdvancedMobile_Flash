import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/feedback_model.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import 'admin_common.dart';
import 'admin_flashcards_screen.dart';
import 'admin_grammar_examples_screen.dart';
import 'admin_quiz_questions_screen.dart';

/// Khoảng ngày [range] (gồm cả hai đầu, theo giờ máy) -> cận `from` / `to` gửi lên API.
/// `from` là 00:00:00 của ngày đầu, `to` là 23:59:59.999 của ngày cuối.
({DateTime? from, DateTime? to}) feedbackDateBounds(DateTimeRange? range) {
  if (range == null) return (from: null, to: null);
  final s = range.start;
  final e = range.end;
  return (
    from: DateTime(s.year, s.month, s.day),
    to: DateTime(e.year, e.month, e.day, 23, 59, 59, 999),
  );
}

/// Chip trạng thái -> giá trị `isViewed` của bộ lọc: null = tất cả, false = chưa xem, true = đã xem.
enum FeedbackViewFilter {
  all(null),
  unviewed(false),
  viewed(true);

  const FeedbackViewFilter(this.isViewed);
  final bool? isViewed;
}

/// Thay phần tử có [id] trong [items] bằng [updated]; không có thì giữ nguyên danh sách.
List<FeedbackItem> replaceFeedback(List<FeedbackItem> items, FeedbackItem updated) =>
    [for (final it in items) it.id == updated.id ? updated : it];

class AdminFeedbackScreen extends ConsumerStatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  ConsumerState<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends ConsumerState<AdminFeedbackScreen> {
  static const _pageSize = 20;

  final _scroll = ScrollController();
  FeedbackType? _type;
  FeedbackViewFilter _view = FeedbackViewFilter.all;
  DateTimeRange? _range;

  List<FeedbackItem> _items = const [];
  int _page = 0;
  int _totalPages = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;

  /// Mỗi lần nạp lại tăng 1 để bỏ kết quả của request cũ (đổi bộ lọc khi đang tải).
  int _generation = 0;
  final Set<String> _toggling = {};

  bool get _hasMore => _page + 1 < _totalPages;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients || _loading || _loadingMore || !_hasMore || _error != null) return;
    if (_scroll.position.extentAfter < 300) _load(more: true);
  }

  Future<void> _load({bool more = false}) async {
    final gen = more ? _generation : ++_generation;
    if (more) {
      setState(() => _loadingMore = true);
    } else {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final bounds = feedbackDateBounds(_range);
      final result = await ref.read(feedbackApiProvider).adminList(
            type: _type,
            isViewed: _view.isViewed,
            from: bounds.from,
            to: bounds.to,
            page: more ? _page + 1 : 0,
            size: _pageSize,
          );
      if (!mounted || gen != _generation) return;
      setState(() {
        _items = more ? [..._items, ...result.items] : result.items;
        _page = result.page;
        _totalPages = result.totalPages;
        _total = result.totalElements;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted || gen != _generation) return;
      if (more) {
        showAppSnack(context, errorMessage(e), error: true);
        setState(() => _loadingMore = false);
      } else {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _refresh() => _load();

  void _setType(FeedbackType? t) {
    if (_type == t) return;
    setState(() => _type = t);
    _load();
  }

  void _setView(FeedbackViewFilter v) {
    if (_view == v) return;
    setState(() => _view = v);
    _load();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _range,
      helpText: tr('Chọn khoảng ngày gửi'),
    );
    if (picked == null || !mounted) return;
    setState(() => _range = picked);
    _load();
  }

  void _clearFilters() {
    setState(() {
      _type = null;
      _view = FeedbackViewFilter.all;
      _range = null;
    });
    _load();
  }

  Future<void> _toggleViewed(FeedbackItem item) async {
    if (_toggling.contains(item.id)) return;
    _toggling.add(item.id);
    final target = !item.isViewed;
    // Cập nhật lạc quan, lỗi thì hoàn lại.
    setState(() => _items = replaceFeedback(_items, item.copyWith(isViewed: target)));
    try {
      final saved = await ref.read(feedbackApiProvider).setViewed(item.id, target);
      if (!mounted) return;
      setState(() => _items = replaceFeedback(_items, saved));
    } catch (e) {
      if (!mounted) return;
      setState(() => _items = replaceFeedback(_items, item));
      showAppSnack(context, errorMessage(e), error: true);
    } finally {
      _toggling.remove(item.id);
    }
  }

  void _openTarget(FeedbackItem item) {
    final Widget? screen = switch (item.type) {
      FeedbackType.flashcard => item.topicId == null
          ? null
          : AdminFlashcardsScreen(topicId: item.topicId!, topicTitle: item.parentTitle ?? item.itemTitle),
      FeedbackType.grammar =>
        AdminGrammarExamplesScreen(grammarId: item.grammarLessonId ?? item.itemId, grammarTitle: item.itemTitle),
      FeedbackType.quiz => AdminQuizQuestionsScreen(quizId: item.itemId, quizTitle: item.parentTitle ?? item.itemTitle),
    };
    if (screen == null) {
      showAppSnack(context, tr('Không tìm thấy mục được phản hồi.'), error: true);
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  bool get _filtered => _type != null || _view != FeedbackViewFilter.all || _range != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(tr('Phản hồi từ học viên'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _filters(),
          const SizedBox(height: 4),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _chip(tr('Tất cả'), _type == null, () => _setType(null)),
              _chip('Flashcard', _type == FeedbackType.flashcard, () => _setType(FeedbackType.flashcard)),
              _chip('Grammar', _type == FeedbackType.grammar, () => _setType(FeedbackType.grammar)),
              _chip('Quiz', _type == FeedbackType.quiz, () => _setType(FeedbackType.quiz)),
            ]),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _chip(tr('Tất cả'), _view == FeedbackViewFilter.all, () => _setView(FeedbackViewFilter.all)),
              _chip(tr('Chưa xem'), _view == FeedbackViewFilter.unviewed, () => _setView(FeedbackViewFilter.unviewed)),
              _chip(tr('Đã xem'), _view == FeedbackViewFilter.viewed, () => _setView(FeedbackViewFilter.viewed)),
            ]),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              TextButton.icon(
                onPressed: _pickRange,
                icon: const Icon(Icons.date_range, size: 18),
                label: Text(_range == null
                    ? tr('Lọc theo ngày')
                    : '${formatDate(_range!.start)} - ${formatDate(_range!.end)}'),
              ),
              if (_filtered)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_alt_off, size: 18),
                  label: Text(tr('Xóa lọc')),
                ),
              const Spacer(),
              if (!_loading && _error == null)
                Text(trf('{n} phản hồi', {'n': _total}), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: active ? AppTheme.primaryColor : Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
          child: Text(label,
              style: TextStyle(color: active ? Colors.white : AppTheme.greyColor, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const LoadingView();
    if (_error != null) return AdminErrorView(error: _error!, onRetry: _load);
    if (_items.isEmpty) {
      // ListView để kéo làm mới được cả khi danh sách rỗng.
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 300,
              child: EmptyView(message: tr('Chưa có phản hồi nào'), icon: Icons.feedback_outlined),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        // Chừa chỗ cho thanh điều hướng nổi ở đáy.
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: _loadingMore
                    ? const CircularProgressIndicator()
                    : TextButton(onPressed: () => _load(more: true), child: Text(tr('Tải thêm'))),
              ),
            );
          }
          return _card(_items[index]);
        },
      ),
    );
  }

  Color _typeColor(FeedbackType t) => switch (t) {
        FeedbackType.flashcard => const Color(0xFF3366FF),
        FeedbackType.grammar => const Color(0xFF8B5CF6),
        FeedbackType.quiz => const Color(0xFFFF9F1C),
      };

  String _typeLabel(FeedbackType t) => switch (t) {
        FeedbackType.flashcard => 'Flashcard',
        FeedbackType.grammar => 'Grammar',
        FeedbackType.quiz => 'Quiz',
      };

  String _formatDateTime(DateTime d) {
    final l = d.toLocal();
    final hh = l.hour.toString().padLeft(2, '0');
    final mm = l.minute.toString().padLeft(2, '0');
    return '${formatDate(l)} $hh:$mm';
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      );

  Widget _targetLine(FeedbackItem item) {
    final String text;
    if ((item.parentTitle ?? '').isNotEmpty && item.type != FeedbackType.grammar) {
      text = '${item.parentTitle}  •  ${item.itemTitle}';
    } else {
      text = item.itemTitle;
    }
    return Row(
      children: [
        const Icon(Icons.label_outline, size: 16, color: AppTheme.greyColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryColor)),
        ),
      ],
    );
  }

  Widget _card(FeedbackItem item) {
    final user = item.createdBy;
    final color = _typeColor(item.type);
    return Card(
      elevation: item.isViewed ? 1 : 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Text(initialsOf(user.fullName).isEmpty ? '?' : initialsOf(user.fullName),
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName,
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(user.email,
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _badge(item.isViewed ? tr('Đã xem') : tr('Chưa xem'), item.isViewed ? Colors.green : Colors.red),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _badge(_typeLabel(item.type), color),
                const SizedBox(width: 8),
                Text(_formatDateTime(item.createdAt), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            _targetLine(item),
            const SizedBox(height: 8),
            Text(item.content, style: const TextStyle(fontSize: 14, height: 1.4)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 0,
              alignment: WrapAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _toggling.contains(item.id) ? null : () => _toggleViewed(item),
                  icon: Icon(item.isViewed ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                  label: Text(item.isViewed ? tr('Đánh dấu chưa xem') : tr('Đánh dấu đã xem')),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openTarget(item),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(tr('Mở mục được phản hồi')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
