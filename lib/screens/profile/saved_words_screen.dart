import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/speech.dart';
import '../../core/theme.dart';
import '../../models/flashcard_model.dart';
import '../../models/saved_word_topic_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

/// Toàn bộ từ vựng người dùng đã lưu (dấu trang trên thẻ từ), đọc từ SQLite nên xem được khi offline.
class SavedWordsScreen extends ConsumerStatefulWidget {
  final String? initialTopicId;

  const SavedWordsScreen({super.key, this.initialTopicId});

  @override
  ConsumerState<SavedWordsScreen> createState() => _SavedWordsScreenState();
}

class _SavedWordsScreenState extends ConsumerState<SavedWordsScreen> {
  final Set<String> _expanded = {};
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTopicId;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _selectedTopicId = widget.initialTopicId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _remove(Flashcard word) async {
    try {
      // BOOKMARK_SET {bookmarked: false}: ghi local trước, đồng bộ sau.
      await ref.read(bookmarkRepositoryProvider).toggle(word.id);
      if (mounted) showAppSnack(context, tr('Đã bỏ lưu từ'), icon: Icons.bookmark_remove);
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    }
  }

  Future<void> _speak(Flashcard word) async {
    final ok = await SpeechService.speak(word.word);
    if (!ok && mounted) {
      showAppSnack(
          context, SpeechService.soundEnabled ? tr('Thiết bị chưa hỗ trợ đọc từ vựng') : tr('Âm thanh đang tắt trong Cài đặt'),
          error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(savedWordTopicsProvider);
    final topics = topicsAsync.value ?? const <SavedWordTopic>[];
    final selectedTopicId =
        _selectedTopicId != null &&
            topics.any((t) => t.topicId == _selectedTopicId)
        ? _selectedTopicId
        : null;
    final words = ref.watch(
      filteredBookmarkedCardsProvider((
        topicId: selectedTopicId,
        keyword: _keyword,
      )),
    );
    final topicTitleById = {for (final t in topics) t.topicId: t.title};
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('Từ đã lưu'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(syncWorkerProvider).syncNow(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            20 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            _filters(
              context,
              topics,
              selectedTopicId,
              loading: topicsAsync.isLoading && topics.isEmpty,
            ),
            const SizedBox(height: 14),
            words.when(
              loading: () => const SizedBox(height: 260, child: LoadingView()),
              error: (e, _) => SizedBox(
                height: 260,
                child: ErrorView(
                  message: trf('Không đọc được dữ liệu: {e}', {'e': e}),
                ),
              ),
              data: (list) => list.isEmpty
                  ? SizedBox(
                      height: 260,
                      child: EmptyView(
                        message: _keyword.isEmpty && selectedTopicId == null
                            ? tr('Chưa có từ nào được lưu')
                            : tr('Không tìm thấy từ đã lưu phù hợp'),
                        icon: Icons.bookmark_border,
                      ),
                    )
                  : Column(
                      children: [
                        for (final word in list)
                          _wordCard(
                            context,
                            word,
                            topicTitle: selectedTopicId == null
                                ? topicTitleById[word.topicId]
                                : null,
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters(
    BuildContext context,
    List<SavedWordTopic> topics,
    String? selectedTopicId, {
    required bool loading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: tr('Tìm từ hoặc nghĩa...'),
            prefixIcon: const Icon(Icons.search, color: AppTheme.greyColor),
            suffixIcon: _keyword.isEmpty
                ? null
                : IconButton(
                    tooltip: tr('Xóa tìm kiếm'),
                    icon: const Icon(Icons.close, color: AppTheme.greyColor),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _keyword = '');
                    },
                  ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF273449)
                : const Color(0xFFF4F6FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) => setState(() => _keyword = value.trim()),
        ),
        const SizedBox(height: 12),
        if (loading)
          const SizedBox(
            height: 36,
            child: Align(
              alignment: Alignment.centerLeft,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tr('Tất cả')),
                    selected: selectedTopicId == null,
                    onSelected: (_) => setState(() => _selectedTopicId = null),
                  ),
                ),
                for (final topic in topics)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 190),
                        child: Text(
                          '${topic.title} (${topic.wordCount})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      selected: selectedTopicId == topic.topicId,
                      onSelected: (_) =>
                          setState(() => _selectedTopicId = topic.topicId),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _wordCard(BuildContext context, Flashcard word, {String? topicTitle}) {
    final open = _expanded.contains(word.id);
    final example = word.example ?? '';
    return GestureDetector(
      onTap: () => setState(() => open ? _expanded.remove(word.id) : _expanded.add(word.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${word.word}  ${word.partOfSpeech.isEmpty ? '' : '(${word.partOfSpeech})'}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 2),
                      Text(word.pronunciation, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(word.meaning, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: tr('Nghe phát âm'),
                  icon: const Icon(Icons.volume_up, color: AppTheme.primaryColor),
                  onPressed: () => _speak(word),
                ),
                IconButton(
                  tooltip: tr('Bỏ lưu'),
                  icon: Icon(Icons.bookmark, color: Colors.amber.shade700),
                  onPressed: () => _remove(word),
                ),
              ],
            ),
            if (open && example.isNotEmpty) ...[
              const Divider(height: 18),
              Text(example, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.4)),
              const SizedBox(height: 4),
              Text(word.exampleTranslation ?? '', style: const TextStyle(color: AppTheme.greyColor, fontSize: 13, height: 1.4)),
            ],
            if (open && word.hasNote) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sticky_note_2_outlined, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Expanded(child: Text(word.note!, style: const TextStyle(fontSize: 13, height: 1.4))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
