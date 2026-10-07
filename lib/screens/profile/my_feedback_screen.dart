import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../providers/feedback_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/feedback_dialog.dart';

/// Góp ý của chính user: lọc theo loại / khoảng ngày, mới nhất trước, tải thêm khi cuộn.
/// Sửa / xóa chỉ được khi admin chưa xem.
class MyFeedbackScreen extends ConsumerStatefulWidget {
  const MyFeedbackScreen({super.key, this.initialType});

  final FeedbackType? initialType;

  @override
  ConsumerState<MyFeedbackScreen> createState() => _MyFeedbackScreenState();
}

class _MyFeedbackScreenState extends ConsumerState<MyFeedbackScreen> {
  final ScrollController _scroll = ScrollController();
  late FeedbackFilter _filter = FeedbackFilter(type: widget.initialType);
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  MyFeedbackListNotifier get _notifier => ref.read(myFeedbackListProvider(_filter).notifier);

  void _onScroll() {
    if (_scroll.hasClients && _scroll.position.extentAfter < 300) _notifier.loadMore();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: _filter.from != null && _filter.to != null ? DateTimeRange(start: _filter.from!, end: _filter.to!) : null,
      saveText: tr('Xong'),
    );
    if (range == null || !mounted) return;
    setState(() => _filter = _filter.copyWith(from: range.start, to: range.end));
  }

  Future<void> _edit(FeedbackItem f) async {
    final ok = await showFeedbackDialog(context, ref, type: f.type, itemId: f.itemId, targetLabel: f.itemTitle, editing: f);
    if (ok && mounted) await _notifier.refresh();
  }

  Future<void> _delete(FeedbackItem f) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Xóa góp ý'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text(tr('Bạn có chắc muốn xóa góp ý này?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(tr('Xóa'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(feedbackApiProvider).delete(f.id);
      _notifier.remove(f.id);
      ref.invalidate(feedbackSummaryProvider);
      if (mounted) showAppSnack(context, tr('Đã xóa góp ý'), icon: Icons.delete_outline);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, feedbackErrorMessage(e, FeedbackAction.delete), error: true);
      // Admin vừa xem: tải lại để nút sửa / xóa phản ánh đúng trạng thái.
      if (isFeedbackAlreadyViewed(e)) _notifier.refresh();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myFeedbackListProvider(_filter));
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Góp ý của tôi'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _typeChips(),
            _dateFilter(),
            Expanded(child: _body(state)),
          ],
        ),
      ),
    );
  }

  Widget _typeChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          children: [
            for (final t in <FeedbackType?>[null, ...FeedbackType.values])
              ChoiceChip(
                key: Key('feedback-chip-${t?.name ?? 'all'}'),
                label: Text(t == null ? tr('Tất cả') : t.label),
                selected: _filter.type == t,
                onSelected: (_) => setState(() => _filter = _filter.copyWith(type: t)),
              ),
          ],
        ),
      ),
    );
  }

  static String _day(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Widget _dateFilter() {
    final from = _filter.from;
    final to = _filter.to;
    final hasRange = from != null && to != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              key: const Key('feedback-date-filter'),
              onPressed: _pickRange,
              icon: const Icon(Icons.date_range, size: 18),
              label: Text(
                hasRange ? '${_day(from)} - ${_day(to)}' : tr('Lọc theo ngày'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (hasRange)
            IconButton(
              key: const Key('feedback-date-clear'),
              tooltip: tr('Xóa lọc'),
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _filter = _filter.copyWith(from: null, to: null)),
            ),
        ],
      ),
    );
  }

  Widget _body(FeedbackListState s) {
    if (s.items.isEmpty) {
      if (s.loading) return const LoadingView();
      if (s.error != null) return ErrorView(message: errorMessage(s.error!), onRetry: _notifier.refresh);
      return RefreshIndicator(
        onRefresh: _notifier.refresh,
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: c.maxHeight,
              child: EmptyView(message: tr('Bạn chưa gửi góp ý nào'), icon: Icons.feedback_outlined),
            ),
          ),
        ),
      );
    }
    // Trang đầu chưa lấp đầy màn hình thì không có gì để cuộn: tự tải tiếp.
    if (s.hasMore && !s.loadingMore && s.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onScroll();
      });
    }
    return RefreshIndicator(
      onRefresh: _notifier.refresh,
      child: ListView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: s.items.length + 1,
        itemBuilder: (context, i) {
          if (i < s.items.length) return _card(s.items[i]);
          if (s.loadingMore) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
          if (s.error != null) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: ErrorView(message: errorMessage(s.error!), onRetry: _notifier.loadMore),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _card(FeedbackItem f) {
    final parent = f.parentTitle ?? '';
    final subtitle = f.type == FeedbackType.flashcard ? parent : '';
    return Container(
      key: Key('feedback-card-${f.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(f.type.icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitle.isNotEmpty)
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                    Text(
                      f.itemTitle.isEmpty ? f.type.label : f.itemTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
              if (f.isViewed) ...[
                const SizedBox(width: 8),
                Container(
                  key: Key('feedback-viewed-${f.id}'),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Text(tr('Đã xem'), style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(f.content, style: const TextStyle(fontSize: 14, height: 1.45)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(f.createdAt.toLocal()),
                  style: const TextStyle(color: AppTheme.greyColor, fontSize: 12),
                ),
              ),
              IconButton(
                key: Key('feedback-edit-${f.id}'),
                tooltip: tr('Sửa'),
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: f.canModify && !_busy ? () => _edit(f) : null,
              ),
              IconButton(
                key: Key('feedback-delete-${f.id}'),
                tooltip: tr('Xóa'),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red,
                onPressed: f.canModify && !_busy ? () => _delete(f) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
