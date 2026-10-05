import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/speech.dart';
import '../../core/theme.dart';
import '../../models/flashcard_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

/// Toàn bộ từ vựng người dùng đã lưu (dấu trang trên thẻ từ), đọc từ SQLite nên xem được khi offline.
class SavedWordsScreen extends ConsumerStatefulWidget {
  const SavedWordsScreen({super.key});

  @override
  ConsumerState<SavedWordsScreen> createState() => _SavedWordsScreenState();
}

class _SavedWordsScreenState extends ConsumerState<SavedWordsScreen> {
  final Set<String> _expanded = {};

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
    final words = ref.watch(bookmarkedCardsProvider);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(tr('Từ đã lưu'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: words.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: trf('Không đọc được dữ liệu: {e}', {'e': e})),
        data: (list) => list.isEmpty
            ? EmptyView(message: tr('Chưa có từ nào được lưu'), icon: Icons.bookmark_border)
            : RefreshIndicator(
                onRefresh: () => ref.read(syncWorkerProvider).syncNow(),
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(context).padding.bottom),
                  itemCount: list.length,
                  itemBuilder: (context, i) => _wordCard(context, list[i]),
                ),
              ),
      ),
    );
  }

  Widget _wordCard(BuildContext context, Flashcard word) {
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
